$(document).on('click', '#toggle-conts-btn', function() {
  console.log(this);
  // toggleConts();
});

function toggleConts(web_id) {
  var element = $(".contWrap#" + web_id);
  console.log(element);

  if (element.is(':visible')) {
    element.hide();
  } else {
    element.show();
  }
}
