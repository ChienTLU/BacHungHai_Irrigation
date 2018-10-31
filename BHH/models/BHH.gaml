/***
* Name: BHH
* Author: hqngh
* Description: 
* Tags: Tag1, Tag2, TagN
***/
model BHH

global {
	file river_shapefile <- file("../includes/river_simple.shp");
	file tram_mua_shapefile <- file("../includes/TramMua.shp");
	file MN_10Cong_20152017 <- csv_file("../includes/MN_10Cong_20152017.csv", ",");
	//	geometry shape<-envelope(tram_mua_shapefile);	//1 7 13 19
	geometry shape <- envelope(river_shapefile); //1 7 13 19
	graph the_graph;
	list ss <- ["C.Xuan Quan", "BÁO ĐÁP", "Kenh Cau", "CẦU CẤT", "LỰC ĐIỀN", "Cong Neo", "Cong Tranh", "C.Ba Thuy", "C.Cau Xe", "C.An Tho"];
	Station source;
	Station dest;
	matrix data <- matrix(MN_10Cong_20152017);

	init {
	//		loop i from: 0 to: 1 {
	//		//loop on the matrix columns
	//			loop j from: 0 to: data.columns - 1 {
	//				write "data rows:" + i + " colums:" + j + " = " + data[j, i];
	//			}
	//
	//		}
		create River from: river_shapefile;
		//		write tram_mua_shapefile.contents;
		create Station from: tram_mua_shapefile;
		source <- (Station where (each.Name = "Song Hong"))[0];
		dest <- (Station where (each.Name = "Song Thai Binh"))[0];
		the_graph <- as_edge_graph(list(River));
		//		the_graph <- the_graph with_optimizer_type "NBAStarApprox";
		do regen;
	}

	action regen {
		ask source {
			ask River overlapping source {
			//			ask River[1] {
				create water {
					myRiver <- myself;
					//					location <- any_location_in(source);
					//					//					target<-any_location_in(dest);
					//					target <- flip(0.9) ? any_location_in(dest) : any_location_in(myself);
					//					location <- (myRiver.shape.points closest_to source.location);
					//					target <- (myRiver.shape.points farthest_to source.location);
					location <- myself.shape.points closest_to source;
					//					location <- any_location_in(myself);
					//						target <- flip(0.9) ? any_location_in(dest) : any_location_in(myself);
					target <- myself.shape.points farthest_to source;
				}

			}

		}

	}

		reflex gen when: flip(0.15) {
//	reflex gen when: source.ll = 0 {
	//	reflex gen {
		do regen;
	}

}

species water skills: [moving] {
	River myRiver;
	point target;
	rgb color <- #blue;
	float size <- 0.00015;
	float sp <- 0.01;
	geometry shape <- circle(size);

	aspect default {
		draw shape color: color;
		draw circle(0.0045) color: color empty: true;
	}

	reflex movement {
		do goto on: the_graph target: target speed: sp;
	//		list<River> o <- ((River) overlapping self);
	//		list<River> rr <- ((River - myRiver) overlapping self);
		list<River> rr <- ((River - myRiver) overlapping myRiver);
		rr<-(rr where ((each.shape.points closest_to self) distance_to self < size*50));
		if (length(rr) > 0 ) {
		//					write rr;
			water w <- self;
			//			write length(rr);
			ask (rr) {
//				write self;
				create water{
					myRiver <- myself;
					//					if(flip(0.5)){
					location <- myself.shape.points closest_to w;
					target <- myself.shape.points farthest_to w;
					//					}else{
//										target <- myself.shape.points closest_to w;
//										location <- myself.shape.points farthest_to w;
					//						
					//					}
					//						location <- any_location_in(myself);
					//						target <- flip(0.9) ? any_location_in(dest) : any_location_in(myself);
					//					location <- (myRiver.shape.points closest_to source.location);
					//					target <- (myRiver.shape.points farthest_to source.location);
				}
			}

						do die;
		}

		if (target != nil and location distance_to target <= sp) {
			do die;
			//		if(location=target){
			//			target <- any_location_in(one_of(River));
		}

	}

}

species River {
	float rrr<-((1+rnd(3))/1000) ;
	rgb color<- rnd_color(255) ;
	reflex ss {
	//		write River where (each touches self);
	}

	aspect default {
		draw shape color: #blue; //rnd_color(255)  ;
//				draw shape+rrr color:color  ;
	}

}

species Station {
	string Name;
	int ll <- 0;
	geometry shape <- rectangle(0.005, 0.005);

	reflex ss {
		list vv <- water at_distance 0.005;
		ll <- length(vv);
		if (ll > 0) {
			(vv[0]).color <- #green;
		}

	}

	aspect default {
		draw rectangle(0.005, 0.005) color: #red;
		draw circle(0.009) color: #red empty: true;
		draw Name + " " + ll size: 10;
	}

}

experiment "main" type: gui {
	output {
		display "s"
		//		type: opengl
		{
			species River aspect: default;
			species Station aspect: default;
			species water;
		}

	}

}