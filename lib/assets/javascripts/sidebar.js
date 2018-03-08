$(document).on('click', '#sidebarCollapse', function() {
  // open sidebar
  $('#sidebar').addClass('active');
  // fade in the overlay
  $('.overlay').fadeIn();
  $('.collapse.in').toggleClass('in');
  $('a[aria-eexpanded=true]').attr('aria-expanded', 'false');
});

$(document).on('click', '#dismiss, .overlay', function() {
  // hide the sidebar
  $('#sidebar').removeClass('active');
  // fade out the overlay
  $('.overlay').fadeOut();
});
