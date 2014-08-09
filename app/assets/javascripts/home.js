//= require jquery
//= require twitter/bootstrap

$(function () {

  $("a[rel=div]").click(function (e) {
      e.preventDefault();
      $($(this).attr("href")).toggle();
  });
  $('#navbar').scrollspy();
  $('.carousel').carousel({
      interval:false
  });

  $('#myTab a').click(function (e) {
      e.preventDefault();
      $(this).tab('show');
  });
});
