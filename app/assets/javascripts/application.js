// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
// require jquery
//
//= require jquery3
//= require popper
//= require bootstrap-sprockets
//= require bootstrap-select
//= require bootstrap/alert
//= require bootstrap/dropdown
//= require jquery_ujs
//= require dataTables/jquery.dataTables
//= require sidebar
//= require turbolinks
//= require underscore
//= require_tree .


  // SHOWS STAFF CONTACTS LIST FROM WEBS VIA BUTTON
  function toggleConts(web_id) {

    var element = $('.showConts[data-id=' + web_id + ']');
    console.log(element.is(':visible'));

    if (element.is(':visible')) {
      element.hide();
    } else {
      element.show();
    }
  }



  // SHOWS Webs LIST FROM Conts VIA BUTTON
  function toggleWeb(id) {

    var element = $(".webWrap#" + id);
    console.log(element);

    if (element.is(':visible')) {
      element.hide();
    } else {
      element.show();
    }
  }


  // Export Webs CSV if Clicked.
  function webExporter() {
      var x = document.getElementById("webExportWrap");
      if (x.style.display === "none") {
          x.style.display = "block";
      } else {
          x.style.display = "none";
      }
  }



  // GENERATES CSV FROM RANSACK QUERY VIA BUTTON
  // function flagDataWeb() {
  //   console.log("flagData Clicked", webs);
  //   $.ajax({
  //     url: "/webs/flag_data",
  //     data: {webs: webs},
  //     success: function() { web.reload(); }
  //   });
  // }



  // $('.collapse').collapse();
