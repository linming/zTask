
/*jslint unparam: true */
/*global window, document, $ */
$(function () {
	'use strict';

	// Start slideshow button:
	$('#start-slideshow').button().click(function () {
		var options = $(this).data(),
		modal = $(options.target),
		data = modal.data('modal');
		if (data) {
			$.extend(data.options, options);
		} else {
			options = $.extend(modal.data(), options);
		}
		modal.find('.modal-slideshow').find('i')
			.removeClass('icon-play')
			.addClass('icon-pause');
		modal.modal(options);
	});

	// Toggle fullscreen button:
	$('#toggle-fullscreen').button().click(function () {
		var button = $(this),
		root = document.documentElement;
		if (!button.hasClass('active')) {
			$('#modal-gallery').addClass('modal-fullscreen');
			if (root.webkitRequestFullScreen) {
				root.webkitRequestFullScreen(
					window.Element.ALLOW_KEYBOARD_INPUT
				);
			} else if (root.mozRequestFullScreen) {
				root.mozRequestFullScreen();
			}
		} else {
			$('#modal-gallery').removeClass('modal-fullscreen');
			(document.webkitCancelFullScreen ||
			 document.mozCancelFullScreen ||
			 $.noop).apply(document);
		}
	});
});



//for file upload
var tpl_box =
	"<div class='box'>\
<div class='name'></div>\
<div class='progresscontainer'><div class='progress'></div></div>\
</div>";

$(document).ready(function() {
	// Check for the various File API support.

	if (window.FormData === undefined) {
		if ( !window.File || !window.FileReader || !window.FileList || !window.Blob )
			alert('Your browser is not supported, Please use the latest version of Firefox, Chrome or Safari for best result.');
	}

	//Listen for file drag and drop
	document.body.addEventListener('dragover', function(e) {
		e.stopPropagation();
		e.preventDefault();
	}, false);
	document.body.addEventListener('drop', function(e) {
		e.stopPropagation();
		e.preventDefault();

		upload_files( e.dataTransfer.files );
	}, false);


	//upload button
	/*
	$('#upload-button').click(function(){
		alert('click upload button');
		$('#files').click();
	});
	*/
	
	//$('#files').change(function(){
	//		upload_files($(this).files);
	//	});
	
});

/*
 * Upload a given FileList
 */
function upload_files( files )
{
	$('#upload-hint').hide();

	//Loop through dropped files, uploading only images and ignoring all others
	for (var i = 0, f; f = files[i]; i++)
		if ( f.type=='image/jpeg' || f.type=='image/png' || f.type=='image/gif' )
			upload_file( f );
	else
		alert( f.name + ' is not a valid image file.' );
}

/*
 * Upload a given File
 */
function upload_file( f )
{
	//Truncate long filenames
	var name = f.name;
	if ( name.length > 15 ) name = name.substr(0, 15)+'...';

	//Create our new upload box to display
	var $box = $(tpl_box).find('.name').html( name ).end();

	//Do the actual uploading
	var XHR = new XMLHttpRequest();
	XHR.open('PUT', '/apis/upload', true);
	//Send the file details along with the request
	for (var key in f)
	{
		var val = f[key];

		//This line is required for Firefox compatability
		if ( typeof(val) == 'string' || typeof(val) == 'number' )
			XHR.setRequestHeader('file_'+key, val);
	}
	//Update our box's progress bar as the file uploads
	XHR.upload.addEventListener("progress", function(e) {
		if ( !e.lengthComputable) return;

		var percentComplete = parseInt(e.loaded / e.total * 100);
		$box.find('.progress').css('width', percentComplete + '%');
	}, false);
	//Display the uploaded pictures thumbnail once upload is complete
	XHR.onreadystatechange = function() {
		// in case of network errors this might not give reliable results
		if ( this.readyState == this.DONE )
			$box.addClass('picture').css('background-image', 'url('+escape(this.responseText)+')');
	}
	XHR.send( f );

	//Display the upload box
	$('#photo-area').append( $box );
}



function toggle_add_to_album() {
	$('#album-name').hide();
	$('#album-list').show();
	$('#add-to-album').hide();
	$('#create-new-album').show();
	$('#btn-create-album').hide();
	$('#btn-upload-photos').show();
}

function toggle_create_new_album() {
	$('#album-name').show();
	$('#album-list').hide();
	$('#add-to-album').show();
	$('#create-new-album').hide();
	$('#btn-create-album').show();
	$('#btn-upload-photos').hide();
}

function upload_photos(is_new) {
	var album_id = 0;
	var album_name = '';
	if (is_new) {
		album_name = $('#album-name').val();
	} else {
		album_id = $('#album-list').val();
	}
	$.get("/albums/upload_photos", { album_id: album_id, album_name: album_name},
		  function(data){
			  window.location = "/albums/view/" + data;
			  //$('#upload-photos-box').modal('hide');
			  //alert("Data Loaded: " + data);
		  }, 'json');
}

function show_create_album_dialog() {
	toggle_create_new_album();
	$('#upload-photos-box').modal('show');
}

function show_add_to_album_dialog(album_rowid) {
	toggle_add_to_album();
	$('#album-list').val(album_rowid);
	$('#upload-photos-box').modal('show');
}