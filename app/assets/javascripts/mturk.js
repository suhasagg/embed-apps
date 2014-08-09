/**
* Mechanical Turk Facilitator class

add this script in your html code:
  <script src="/assets/mturk.js"></script>

then you can use the following method in your microapp:

    var app = new VolatileTask(...)

    //to enable mturk
    app.activate_mturk_env({sandbox:true});
    
    // to check of if we are in a mturk environment 
    // i.e. if the url contains 'assignmentId' parameters
    // return true or false
    app.mturk_env_detected
    
    // submit the HIT to the mturk platform
    app.finish_HIT();
    
    //or submit the HIT with data 
    app.finish_HIT({param1: val1, param2: val2});

*/


VolatileTaskApp.prototype.activate_mturk_env = function (options){
  options = options ? options : {sandbox:false};
  this.form = $("<form method='POST' id='form_mturk'>");
  $("body").append(this.form);

  var assignment=$.urlParam('assignmentId');
  if (assignment !== 0){
    console.log("mturk environment detected.");
    this.env_detected = true;
    this.add_hidden_input("assignmentId",assignment);
    this.set_sandbox(options.sandbox);
  } else {
    this.env_detected = true;
    console.log("mturk environment not detected.");
  }
  return (this.mturk_detected);
};

VolatileTaskApp.prototype.set_sandbox = function (sandbox){
  console.log("sandbox env: "+sandbox);
  var turk_url = (sandbox)? "https://workersandbox.mturk.com/mturk/externalSubmit" : "https://www.mturk.com/mturk/externalSubmit";
  this.form.attr("action",turk_url);
};

VolatileTaskApp.prototype.add_hidden_input = function (name, value){
  this.form.append("<input type='hidden' name='" + name + "' value='" + value + "' />");
};

VolatileTaskApp.prototype.finish_HIT = function (hash_data){
  if (hash_data !== undefined){
    $each(hash_data, function(name, value){
      this.add_hidden_input(name,data);
    });
  }
  this.form.submit();
};

/**
 * Helper 
 **/
$.urlParam = function(name){
  var results = new RegExp('[\\?&]' + name + '=([^&#]*)').exec(window.location.href);
    if (results == null){
    return 0;
  }else{
    return results[1] || 0;
  }
};