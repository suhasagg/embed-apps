
GF_TABLE_BASE_URL = "https://www.google.com/fusiontables/DataSource?docid=";

function create_gf_table(mode, form_field, callback) {
  $('#create_' + mode).attr("disabled", true);
  $('#create_' + mode).html("Creating table...");
  $.getJSON("/apps/create_gf_table.json?table=" + mode, function(data) {
      $(form_field).val(GF_TABLE_BASE_URL + data.ft_table_id);
      $('#create_' + mode).hide();
  });
}

function url_google(ft_table) {
    var key = 'AIzaSyDaD2I-HSjUXgmQr9uOvF5-wZTwgfLgW-Q';
    var sqlquery = "DESCRIBE " + ft_table;
    return 'https://www.googleapis.com/fusiontables/v1/query?sql=' + encodeURI(sqlquery) + "&key=" + key;
}

function load_schema(ft_table_id, callback_fct) {
    var columns = [];
    $.ajax({
        url: url_google(ft_table_id),
        success: function(data) {
            $.each(data.rows, function(i, row) {
                columns.push(row[1]);
            });
            $("#task_state").attr("src","");
            $("#task_state").show();
            callback_fct(columns);
        },
        error: function(data) {
            $("#task_state").attr("src","");
            $("#task_state").show();
            $("#task_column").hide();
        }
    });
}

function retrieve_columns_names() {
    var ft_table_id = $('#app_challenges_table_url').val().replace(GF_TABLE_BASE_URL, "");
    load_schema(ft_table_id, function(columns) {
        select = $("#app_task_column");
        select.html("");
        options = "";
        for (var i = 0; i < columns.length; i++) {
            options += "<option value='" + columns[i] + "'>" + columns[i] + "</option>";
        }
        select.append(options)
        $("#task_column").show();
    });
}

function process_table(mode){
  url = $("#app_"+mode+"_table_url").val();
  if (url != "") {
    if (mode == "challenges") {
      retrieve_columns_names();
    }
    link = $("<a href='"+url+"' target='_blank' class='btn btn-primary'>view the "+mode+" table</a>");
    $('#link_' + mode).append(link);
  }
}

$(function() {
  $('a[rel=popover]').popover({
      placement: 'right',
      offset: 5,
      html: true
  });

  $('#app_challenges_table_url').change(function() {
      process_table("challenges");
  });

  process_table("challenges");
  process_table("answers");
});