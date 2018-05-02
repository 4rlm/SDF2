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


  // SHOWS FWD WEB DETAILS FROM WEBS VIA BUTTON
  function toggleFwd(web_id) {
    var element = $('.showFwd[data-id=' + web_id + ']');
    console.log(element.is(':visible'));

    if (element.is(':visible')) {
      element.hide();
    } else {
      element.show();
    }
  }


  // SHOWS Webs LIST FROM Conts VIA BUTTON
  function toggleWeb(cont_id) {
    var element = $('.showWeb[data-id=' + cont_id + ']');
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



  // Webs Header Tip
  function websHeaderTipModal() {
    var el = $('#websHeaderTipModalWrap');
    console.log(el.is(':visible'));

    if (el.is(':visible')) {
      el.hide();
    } else {
      el.show();
    }
  }





  // ========== Admin's user level changer buttons ==========
  var users = new Array();

  function selectUsers(el) {
    var tr = el.parentNode;
    var stat = el.getElementsByClassName('stat-btn')[0];
    var user_id = $(el).data("id");

    if (stat.className.includes('fa-green')) {
      tr.className = ""
      stat.className = "fa fa-check fa-lg stat-btn fa-clear"
      var index = users.indexOf(user_id);
      users.splice(index, 1);
    } else {
      tr.className = "bg-yellow"
      stat.className = "fa fa-check fa-lg stat-btn fa-green"
      users.push(user_id);
    }
  }

  function changeUserLevel(el) {
    var level = $(el).data("level");
    $.ajax({
      url: "/admin/change_user_level",
      data: {users: users, level: level},
      success: function() { location.reload(); }
    });
  }
