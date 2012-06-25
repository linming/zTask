var ori_value = '';
$(document).ready(function() {
	$('#new_task').click(function(){
		$.post($(this).attr('action_url'), {}, function(data){
			$('#markup_new_task').tmpl(data).prependTo(".task_list");
			$('.task_list').children(':first').find('textarea:first').focus();
		}, 'json');

	});

	$('#delete_task').click(function(){
		if (confirm('你确定要删除这个任务吗?')){
			var task_id = $('#panel_frame').attr('data_id');
			$.post('./tasks/delete', {task_id: task_id}, function(data){
				$('.drawpanel').animate({left: 0});
			}, 'json');			
		}
	});

	$('.task .task_checkbox_real').change(function(){
		var task_li = $(this).parent().parent().parent();
		var is_checked = $(this).is(':checked');
		var status = is_checked ? 'completed' : 'ongoing';

		$.post('./tasks/edit/' + task_li.attr('data_id'), {status: status}, function(data){
			task_li.attr('class', data.status);			
		}, 'json');
	});

	$('.task_list li').live('click', function(){
		$('.task_list li').removeClass('selected');
		$(this).addClass('selected');
		//draw panel
		var selected_id = $(this).attr('data_id');
		var detail_id = $("#panel_frame").attr('data_id');

		if(selected_id != detail_id) {
			$('#panel_frame').attr('data_id', selected_id);
			//load data
			$.get('./tasks/view/' + selected_id, {}, function(data){
				$('#assignee').val(data.assignee_nick);
				$('#task_desc').val(data.description);
				$('#due_date').val(data.due_date);
				$('#tasks_logs').html($('#markup_task_log').tmpl(data.tasks_logs));
			}, 'json');
		}

		var panel = $('.drawpanel');
		if (parseInt(panel.css('left'), 0) == 0) {
			panel.animate({left: panel.outerWidth() - 3});
		}

	});

	$('.task .title').live('click', function(){

		//editable

		var parent = $(this).parent();
		parent.html('<textarea onblur="task_save_title(this)" onfocus="store_ori_value(this)" style="width: 360px; height: 22px;">' + $(this).text() + '</textarea>');
		parent.children(':first').focus();

		return true;
	});
	
	$('.close').click(function() {
		var panel= $('.drawpanel');
		panel.animate({left: 0});
		return false;
	});

});

function store_ori_value(target) {
	ori_value = $(target).val();
}

function task_save_title(textarea) {
	if ($(textarea).val() == ori_value) {
		$(textarea).parent().html('<span class="title">'+$(textarea).val()+'</span>');
		return;
	}
	$.post('./tasks/edit/' + $(textarea).parent().parent().parent().attr('data_id'), {title: $(textarea).val()}, function(data){
		$(textarea).parent().html('<span class="title">'+$(textarea).val()+'</span>');
	}, 'json');
}

function task_save_desc(textarea) {
	var desc = $(textarea).val();
	if (desc == ori_value) {
		return;
	}

	$.post('./tasks/edit/' + $('#panel_frame').attr('data_id'), {description:desc}, function(data){
		
	}, 'json');
}

function task_save_assignee(textfield) {
	var assignee = $(textfield).val();
	if (assignee == ori_value) {
		return;
	}

	if (assignee.indexOf(';') != -1) {
		assignee = assignee.substring(0, assignee.indexOf(';'));
	}
	$.post('./tasks/edit/' + $('#panel_frame').attr('data_id'), {assignee:assignee}, function(data){
		$(textfield).val(assignee);
	}, 'json');
}

function task_save_due_date(textfield) {
	var due_date = $(textfield).val();
	if (due_date == ori_value) {
		return;
	}

	$.post('./tasks/edit/' + $('#panel_frame').attr('data_id'), {due_date:due_date}, function(data){

	}, 'json');
}

function date_select_callback() {
	var textfield = document.getElementById("due_date");
	task_save_due_date(textfield);
}

function show_real_input() {
	$('#task_input_fake_tips').hide();
	$('#task_comment_owner').show();
	$('#task_comment_main').show();
	$('#comment_textarea').focus();
}
function hide_real_input() {
	$('#task_comment_owner').hide();
	$('#task_comment_main').hide();
	$('#task_input_fake_tips').show();
}

function fit_to_content(id, maxHeight) {
	var text = id && id.style ? id : document.getElementById(id);
	if ( !text )
		return;

	var adjustedHeight = text.clientHeight;
	if ( !maxHeight || maxHeight > adjustedHeight )
	{
		adjustedHeight = Math.max(text.scrollHeight, adjustedHeight);
		if ( maxHeight )
			adjustedHeight = Math.min(maxHeight, adjustedHeight);
		if ( adjustedHeight > text.clientHeight )
			text.style.height = adjustedHeight + "px";
	}
}

function do_comment_summit(event) {
	if (event.keyCode === 13 && !event.ctrlKey) {
		var content = $('#comment_textarea').val();
		if (content == '\n') {
			$('#comment_textarea').val('');
			return false;
		}

		var task_id = $('#panel_frame').attr('data_id');
		
		$.post("./tasks/add_comment",
			   {task_id: task_id, memo: content},
			   function(data) {
				   $('#markup_task_log').tmpl(data).prependTo('#tasks_logs');
			   },
			  'json');
		
		hide_real_input();
		$('#comment_textarea').val('');
		return false;
	}

	fit_to_content('comment_textarea', 100);

	return true;
}