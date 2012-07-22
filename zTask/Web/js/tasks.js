var ori_value = '';

$.fn.selectRange = function(start, end) {
	return this.each(function() {
		if (this.setSelectionRange) {
			this.focus();
			this.setSelectionRange(start, end);
		} else if (this.createTextRange) {
			var range = this.createTextRange();
			range.collapse(true);
			range.moveEnd('character', end);
			range.moveStart('character', start);
			range.select();
		}
	});
};


$(document).ready(function() {

	$("#due_date").datepicker({	 
		dateFormat: 'yy-mm-dd',
		onSelect: function(dateText, inst) {
			var textfield = document.getElementById("due_date");
			task_save_due_date(textfield);
		}
	});
	$("#project").chosen({allow_single_deselect:true});
	
	$('#new_task').click(function(){
		$.post('/tasks/add', {}, function(data){
			$('#markup_new_task').tmpl(data).prependTo(".task_list");
			$('.task_list').children(':first').find('textarea:first').focus();
		}, 'json');

	});

	$('#delete_task').click(function(){
		bootbox.confirm("Are you sure to delete this task?", function(result) {
			if (result) {
				var task_id = $('#panel_frame').attr('data_id');
				$.post('/tasks/delete', {task_id: task_id}, function(data){
					$('#task-'+task_id).fadeOut(1000, function(){$(this).remove();});
					$('.drawpanel').animate({left: 0});
				}, 'text');			
			} else {
			}
		});
	});

	$('.task .task_checkbox_real').change(function(event){
		event.stopPropagation();
		var task_li = $(this).parent().parent().parent();
		var is_checked = $(this).is(':checked');
		var status = is_checked ? 1 : 0;

		$.post('/tasks/edit/' + task_li.attr('data_id'), {status: status}, function(data){
			task_li.attr('class', 'status-' + status);			
		}, 'json');
	});

	$('.task_list li').on('click', function(){
		$('.task_list li').removeClass('selected');
		$(this).addClass('selected');
		//draw panel
		var selected_id = $(this).attr('data_id');
		var detail_id = $("#panel_frame").attr('data_id');

		if(selected_id != detail_id) {
			$('#panel_frame').attr('data_id', selected_id);
			//load data
			$.get('/tasks/view/' + selected_id, {}, function(data){
				$('#project').val(data.project_id);
				$("#project").trigger("liszt:updated");
				$('#note').val(data.note);
				$('#due_date').val(data.due_date);
				$('#created').text('created at ' + data.created);
				for (i = 0; i < data.attaches.length; i++) {
					var attach = data.attaches[i];
					if (attach.type == 'Audio') {
						$('#attaches').append($('#markup_task_attach_audio').tmpl(attach));
					} else {
						$('#attaches').append($('#markup_task_attach_photo').tmpl(attach));
					}
				}
			}, 'json');
		}

		var panel = $('.drawpanel');
		if (parseInt(panel.css('left'), 0) == 0) {
			panel.animate({left: panel.outerWidth() - 3});
		}

	});

	$('.task_list li').on('mouseover', function(){
		$(this).find('.flag-gray').css('visibility', 'visible');
	});

	$('.task_list li').on('mouseout', function(){
		$(this).find('.flag-gray').css('visibility', 'hidden');
	});

	$('.flag').on('click', function(event){
		event.stopPropagation();
		var flag = $(this);
		$.post('/tasks/edit/' + flag.parent().parent().parent().attr('data_id'),
			   {flag: (flag.attr('data') == 1 ? 0 : 1) }, function(data){
				   if (flag.attr('data') == 1) {
					   flag.attr('data', 0);
					   flag.removeClass('flag-red').addClass('flag-gray');
				   } else {
					   flag.attr('data', 1);
					   flag.removeClass('flag-gray').addClass('flag-red');
					   flag.css('visibility', 'visible');
				   }
		}, 'json');
	});

	$('.task .title').live('click', function(){
		//editable
		var parent = $(this).parent();
		parent.html('<input onblur="task_save_title(this)" onfocus="store_ori_value(this)"/>');
		var title_input = parent.children(':first');
		title_input.val($(this).text());
		title_input.focus();
		var length = title_input.val().length;
		title_input.selectRange(length, length);
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

function task_save_title(textinput) {
	if ($(textinput).val() == ori_value) {
		$(textinput).parent().html('<span class="title">'+$(textinput).val()+'</span>');
		return;
	}
	$.post('/tasks/edit/' + $(textinput).parent().parent().parent().attr('data_id'), {title: $(textinput).val()}, function(data){
		$(textinput).parent().html('<span class="title">'+$(textinput).val()+'</span>');
	}, 'json');
}

function task_save_note(textarea) {
	var note = $(textarea).val();
	if (note == ori_value) {
		return;
	}

	$.post('/tasks/edit/' + $('#panel_frame').attr('data_id'), {note:note}, function(data){
		
	}, 'json');
}

function task_save_project(select) {
	var project_id = $(select).val();
	if (project_id == ori_value) {
		return;
	}
	$.post('/tasks/edit/' + $('#panel_frame').attr('data_id'), {project_id:project_id}, function(data){	
	}, 'json');
}

function task_save_due_date(textfield) {
	var due_date = $(textfield).val();
	if (due_date == ori_value) {
		return;
	}

	$.post('/tasks/edit/' + $('#panel_frame').attr('data_id'), {due_date:due_date}, function(data){

	}, 'json');
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
		
		$.post("/tasks/add_comment",
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