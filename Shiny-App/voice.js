function Sound(source,volume,loop)
{
    this.source=source;
    this.volume=volume;
    this.loop=loop;
    var son;
    this.son=son;
    this.finish=false;
    this.stop=function()
    {
        document.body.removeChild(this.son);
    }
    this.start=function()
    {
        if(this.finish)return false;
        this.son=document.createElement("embed");
        this.son.setAttribute("src",this.source);
        this.son.setAttribute("hidden","true");
        this.son.setAttribute("volume",this.volume);
        this.son.setAttribute("autostart","true");
        this.son.setAttribute("loop",this.loop);
        document.body.appendChild(this.son);
    }
    this.remove=function()
    {
        document.body.removeChild(this.son);
        this.finish=true;
    }
    this.init=function(volume,loop)
    {
        this.finish=false;
        this.volume=volume;
        this.loop=loop;
    }
}

var initVoice = function() {
if (annyang) {
var x = new Sound("beep.mp3",100,false);
  var commands = {
	'US News' : function() {
    	window.open('https://usnews.com', '_blank');
    },
    'Private' : function() {
    	Shiny.onInputChange('schools', "Private");
    },
    'Public' : function() {
    	Shiny.onInputChange('schools', "Public");
    },
    'why *v' : function(v) {
    	if (v == "endowment") {
    		Shiny.onInputChange('y', "Endowment");
    	} else if (v == "acceptance rate") {
    		Shiny.onInputChange('y', "Acc_Rate");
    	} else if (v == "median start salary") {
    		Shiny.onInputChange('y', "Median_Start_Sal");
    	} else if (v == "score") {
    		Shiny.onInputChange('y', "Score");
    	} else if (v == "tuition") {
    		Shiny.onInputChange('y', "Tuition");
    	}  
    },
    'x *v' : function(v) {
    	if (v == "endowment") {
    		Shiny.onInputChange('x', "Endowment");
    	} else if (v == "acceptance rate") {
    		Shiny.onInputChange('x', "Acc_Rate");
    	} else if (v == "median start salary") {
    		Shiny.onInputChange('x', "Median_Start_Sal");
    	} else if (v == "score") {
    		Shiny.onInputChange('x', "Score");
    	} else if (v == "tuition") {
    		Shiny.onInputChange('x', "Tuition");
    	}  
    },
    'title *x' : function(x){
    	Shiny.onInputChange('plot_title', x);
    }
};
  annyang.addCommands(commands);
  annyang.start();
  }
};

$(function() {
  setTimeout(initVoice, 5);
});