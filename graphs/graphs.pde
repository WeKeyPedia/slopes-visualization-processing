import java.util.*;
import java.util.Map;

String data_source = "/Users/tk/Dropbox/code/wekeypedia/slopes-builder/path_points";
//String data_source = ".";

int w = 800;
int h = 205*5 + 5;

int bar_max = 200;
int bar_width = 5;
int offset = 1;

//PFont avenir = loadFont("AvenirNext-DemiBold-64.vlw");
PFont avenir = createFont("AvenirNext-DemiBold", 64);

class Segment {
  String title;
  int length;
  int pageid;
  float specialization = 0;
  int revisions;
  int quality;
  color c;
}

class OrderBySpec implements Comparator<Segment>{
  int compare(Segment s1, Segment s2){
    return (s1.specialization <  s2.specialization ? -1 :
           (s1.specialization == s2.specialization ?  0 : 1));
  }
}

class OrderByPageId implements Comparator<Segment>{
  int compare(Segment s1, Segment s2){
    return (s1.pageid <  s2.pageid ? -1 :
           (s1.pageid == s2.pageid ?  0 : 1));
  }
}

class OrderByLength implements Comparator<Segment>{
  int compare(Segment s1, Segment s2){
    return (s1.length <  s2.length ? -1 :
           (s1.length == s2.length ?  0 : 1));
  }
}

class OrderByQuality implements Comparator<Segment>{
  int compare(Segment s1, Segment s2){
    return (s1.quality <  s2.quality ? -1 :
           (s1.quality == s2.quality ?  0 : 1));
  }
}

class OrderByRevisions implements Comparator<Segment>{
  int compare(Segment s1, Segment s2){
    return (s1.revisions <  s2.revisions ? -1 :
           (s1.revisions == s2.revisions ?  0 : 1));
  }
}

HashMap<String, Segment> specialization = new HashMap<String, Segment>();

ArrayList<Segment> pages = new ArrayList<Segment>();

int max_length = 0;

void load_data(){
  JSONArray spec_json = loadJSONArray("../data/geometry.json");

  for( int i=0; i < spec_json.size(); i++){
    JSONObject o = spec_json.getJSONObject(i);

    Segment s = new Segment();

    String t = o.getString("pagename");
    s.specialization = o.getFloat("specialization");
    s.quality = o.getInt("quality.of.the.article");
    s.revisions = o.getInt("number.of.revisions");

    specialization.put(t, s);
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
      int pageid = page.getJSONObject(k).getInt("pageid");

      p.length = l;
      p.pageid = pageid;
      
      max_length = max(l, max_length);
    }

    if(specialization.containsKey(title)){
      Segment spec_obj = specialization.get(title);

      p.specialization = spec_obj.specialization;
      println(spec_obj.specialization);
  
      p.quality = spec_obj.quality;
      p.revisions = spec_obj.revisions;
      
      pages.add(p);
    } else {
      println("WARNING: <"+title+"> has no specialization indice");
    }
    

    //pages.add(p);
  }  
}


void setup(){
  background(220);
  load_data();

  size(pages.size() * (bar_width + offset) + 10, h);

  println("# pages: "+ pages.size());
  noLoop();

}
int current_page_index = 0;



void draw(){
   noStroke();

  int x = 5;
  int y = 5;
  
  int i = 0;
  int s = pages.size();
 
  float r = float(bar_max) / float(max_length);
 
  textFont(avenir, 64);
  fill(255);

  /**************************/
  /* QUARTILES              */
  /**************************/

  text("quartiles", 5, 69); 
 
  Collections.sort(pages, new OrderBySpec());

  for(Segment p : pages){
    x = 5 + (bar_width + offset) * i;

    int l = max(int(p.length * r),5);
    y = 5 + bar_max - l;

//    int c = 150;
//    int alpha = floor(255 - 255 * p.specialization);

    color c = 0;
    
    float q = float(i)/float(s);
//    println(q);
    if(q < 0.25){
      c = #2EAC66;
    } else if(( q >= 0.25) && (q < 0.50)){
      c = #009EE3;
    } else if(( q >= 0.50) && (q < 0.75)){
      c = #E24352;
    } else if( q >= 0.75){
      c = #1C1C1B;
    }

    p.c = c;

    int alpha = 255;

    fill(c,alpha);
    rect(x, y, bar_width, l);    

    i++;
  }

  /**************************/
  /* PAGE ID                */
  /**************************/

  fill(255);
  text("page id", 5, 274); 

  Collections.sort(pages, new OrderByPageId());

  i = 0;

  for(Segment p : pages){
    x = 5 + (bar_width + offset) * i;

    int l = max(int(p.length * r),5);
    y = 205 + 5 + bar_max - l;

//    int c = 150;
//    int alpha = floor(255 - 255 * p.specialization);

    color c = p.c;    
    int alpha = 255;

    fill(c,alpha);
    rect(x, y, bar_width, l);    

    i++;
  }

  /**************************/
  /* LENGTH                 */
  /**************************/

  fill(255);
  text("length", 5, 479); 

  Collections.sort(pages, new OrderByLength());

  i = 0;

  for(Segment p : pages){
    x = 5 + (bar_width + offset) * i;

    int l = max(int(p.length * r),5);
    y = 410 + 5 + bar_max - l;

//    int c = 150;
//    int alpha = floor(255 - 255 * p.specialization);

    color c = p.c;    
    int alpha = 255;

    fill(c,alpha);
    rect(x, y, bar_width, l);    

    i++;
  }

  /**************************/
  /* QUALITY                */
  /**************************/

  fill(255);
  text("quality", 5, 684); 

  Collections.sort(pages, new OrderByQuality());

  i = 0;

  for(Segment p : pages){
    x = 5 + (bar_width + offset) * i;

    int l = max(int(p.length * r),5);
    y = 615 + 5 + bar_max - l;

//    int c = 150;
//    int alpha = floor(255 - 255 * p.specialization);

    color c = p.c;    
    int alpha = 255;

    fill(c,alpha);
    rect(x, y, bar_width, l);    

    i++;
  }
  
  /**************************/
  /* NB OF REVS             */
  /**************************/

  fill(255);
  text("revisions", 5, 889); 

  Collections.sort(pages, new OrderByRevisions());

  i = 0;

  for(Segment p : pages){
    x = 5 + (bar_width + offset) * i;

    int l = max(int(p.length * r),5);
    y = 820 + 5 + bar_max - l;

//    int c = 150;
//    int alpha = floor(255 - 255 * p.specialization);

    color c = p.c;    
    int alpha = 255;

    fill(c,alpha);
    rect(x, y, bar_width, l);    

    i++;
  }
}
