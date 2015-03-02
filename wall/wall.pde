import java.util.*;

String data_source = "/Users/tk/Dropbox/code/wekeypedia/slopes-builder/path_points";
//String data_source = ".";

class Segment {
  String title;
  int length;
  float specialization = 0;
}

class OrderBySpec implements Comparator<Segment>{
  int compare(Segment s1, Segment s2){
    return (s1.specialization <  s2.specialization ? -1 :
           (s1.specialization == s2.specialization ?  0 : 1));
  }
}

FloatDict specialization = new FloatDict();

int w = 800;
int h = 800;

ArrayList<Segment> pages = new ArrayList<Segment>();

void load_data(){
  JSONArray spec_json = loadJSONArray("../data/geometry.json");

  for( int i=0; i < spec_json.size(); i++){
    JSONObject o = spec_json.getJSONObject(i);
    String t = o.getString("pagename");
    Float v = o.getFloat("specialization");
    specialization.set(t,v);
  }

  File dir = new File(data_source);
  
  String[] list = dir.list();

  for (String f : list){
    JSONObject json;
    
    json = loadJSONObject(data_source+"/"+f);
    //println(json);
    
    JSONObject page = json.getJSONObject("query").getJSONObject("pages");
    
    String k = (String)page.keys().toArray()[0];  
//    println(k);

    Segment p = new Segment();

    String title = page.getJSONObject(k).getString("title");
//    println(title);
    p.title = title;
    
    if(page.getJSONObject(k).hasKey("length")){
      int l = page.getJSONObject(k).getInt("length");
      p.length = l;
    }

    p.specialization = specialization.get(title);

    pages.add(p);
  }  
}


void setup(){
  size(h,w);
  background(220);
  load_data();
  println("# pages: "+ pages.size());
  noLoop();

}
int current_page_index = 0;



void draw(){
   noStroke();

  int x = 5;
  int y = 5;

  int bar_width = 5;
  int offset = 2;
  
  Collections.sort(pages, new OrderBySpec());
  
  int i = 0;
  int s = pages.size();
 
  for(Segment p : pages){
    int l = max(p.length/100,5);

    if (l > h){
      println(l);
    }

    if (( y + l ) > h){
      y = 5;
      x += bar_width + offset;
    }

//    int c = 150;
//    int alpha = floor(255 - 255 * p.specialization);

    color c = 0;
    
    float q = float(i)/float(s);
    println(q);
    if(q < 0.15){
      c = #2EAC66;
    } else if(( q >= 0.15) && (q < 0.50)){
      c = #009EE3;
    } else if(( q >= 0.50) && (q < 0.85)){
      c = #E24352;
    } else if( q >= 0.85){
      c = #1C1C1B;
    }

    int alpha = 255;

    fill(c,alpha);
    rect(x, y, bar_width, l);    

    y += l + offset;
    i++;
  }
}
