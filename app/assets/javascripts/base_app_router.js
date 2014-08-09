/**

This is a backbone router ( http://backbonetutorials.com/what-is-a-router/ ) for a basic microapp

Any router can be extended by the method app.add_route of any microapp

app.add_route(routepattern, function(parameter){
  ...
});

This router follows these conventions:

1. app.navigate("static/mysection") will display
<section id="mysection">...</section>
and hide the other <section> tags
e.g. app.navigate("static/intro") to start your app with an instruction panel <section id="intro">

2. app.navigate("play") will load the next task e.g. task with ID =12
and then executes app.navigate("tasks/12")
that call router.task(id) function

*/
var BasicAppRouter = Backbone.Router.extend({

    routes: {
        "play" :"play",
        "tasks/:id" : "task",
        "static/:name" : "static_content"
    },

    initialize:function(options){
      this.app=options.app;
    },

    static_content:function(name){
       $("section").hide(); $("#"+name).show();
    },

    play:function(){
      console.log("Play state");
      this.static_content("task");
      this.app.tasks.next();
    },

    task:function(id){
      // to implement
      // task=this.app.tasks.get(id);
    }
  });