$(document).ready(function() {
});


// プレビューモーダルが開かれた時に画像を読み込み
$('.modal').on('shown', function() {
	var id = $(this).attr('id');
	var name = $("input[name='files[" + id + "]']").attr('value'); //画像ファイル名
	var album_name = $('#album_name').text(); //アルバム名
	var modal_body = $(this).children('.modal-body'); //.modal-body 部分のセレクタ
	
	// プレビュー表示
	if (!modal_body.children('div').children().is('img')) {
		modal_body.append("<div align='center'><img src='/previews/" 
			+ album_name + "/" + name + "' width=520px></div>");
	}
});

$('.check-btn#true').bind('click', function() {
	$('input[type=checkbox]').attr('checked', true);
});

$('.check-btn#false').bind('click', function() {
	$('input[type=checkbox]').attr('checked', false);
});
