/***
* Name: BHH
* Author: hqngh
* Description: 
* Tags: Tag1, Tag2, TagN
***/
model BHH

global {
	file river_region_shapefile <- file("../includes/SongBHH_region.shp");
	file river_shapefile <- file("../includes/river_simple1.shp");
	file tram_mua_shapefile <- file("../includes/TramMua.shp");
	file MN_10Cong_20152017 <- csv_file("../includes/MN_10Cong_20152017.csv", ",");
	//	geometry shape<-envelope(tram_mua_shapefile);	//1 7 13 19
	geometry shape <- envelope(river_shapefile); //1 7 13 19
	graph the_graph;
	list ss <- ["C.Xuan Quan", "BÁO ĐÁP", "Kenh Cau", "CẦU CẤT", "LỰC ĐIỀN", "Cong Neo", "Cong Tranh", "C.Ba Thuy", "C.Cau Xe", "C.An Tho"];
	Station source;
	Station dest;
	matrix<float, float> data <- matrix<float>(matrix(MN_10Cong_20152017));

	init {
		create River_region from: river_region_shapefile;
		create River from: river_shapefile;
		//		write tram_mua_shapefile.contents;
		create Station from: tram_mua_shapefile;
		loop i from: 0 to: data.rows - 1 {
		//loop on the matrix columns
			loop j from: 0 to: data.columns - 1 {
			//				write "data rows:" + i + " colums:" + j + " = " + data[j, i];
				Station st <- first(Station where (each.Name = ss[j]));
				if (st != nil) {
					st.heso <+ data[j, i];
				}

			}

		}

		source <- (Station where (each.Name = "Song Hong"))[0];
		dest <- (Station where (each.Name = "Song Thai Binh"))[0];
		the_graph <- as_edge_graph(list(River));
		the_graph <- the_graph with_optimizer_type "NBAStarApprox";
		//		do regen;
//		create people number: 650 {
//			b <- any(River_region); 
//			location <- any_location_in(b); 
//
//			t <- b.points farthest_to location;
//		}

	}

	action regen {
	//		ask source {
		ask River overlapping source {
		//				ask River[1] {
		//		ask any(River) {
			create water {
				myRiver <- myself;
				//				location <- any_location_in(myRiver);
				//				target <- any_location_in(myRiver);
				//					target <- flip(0.9) ? any_location_in(dest) : any_location_in(myself);
				location <- (myRiver.shape.points closest_to source.location);
				target <- (myRiver.shape.points farthest_to source.location);
				//									target <- (myRiver.shape.points closest_to source.location);
				//									location <- (myRiver.shape.points farthest_to source.location);
				//				location <- flip(0.5) ? first(myself.shape.points) : any_location_in(myself);
				//				target <- flip(0.5) ? last(myself.shape.points) : any_location_in(myself);
				//						target <- flip(0.9) ? any_location_in(dest) : any_location_in(myself);
				//				location <- first(myself.shape.points);
				//				target <- last(myself.shape.points);
			}

		}

		//			}
		//
		//		}

	}

	//	reflex gen when: flip(0.05) {
	reflex gen when: source.ll = 0 {
	//			reflex gen {
	//			loop times: 20 {
			do regen;
	//			}

	}

}

species water skills: [moving] {
	River myRiver;
	point target;
	rgb color <- #blue;
	float size <- 0.005;
	float sp <- 0.005;
	//	geometry shape <- circle(size);
	geometry shape <- rectangle(size * 2, size);
	//	int flag <- 0;
	aspect default {
		draw shape color: color rotate: heading;
		//		draw circle(0.0045) color: color empty: true;
		//		draw line(location, target) color: #red;
		//		ask rr{
		//			
		//			draw line(myself.location, self.shape.points[0]) color: #red;
		//		}
	}

	list<River> rr <- [];

	reflex regen {
//		write current_edge as River;
		list<River> o <- ((River - River(current_edge)) overlapping self);
		rr <- River - o; //((River - o) overlapping self);
		rr <- (rr where ((each.shape.points closest_to self) distance_to self < size));
		list<water> ww <- (water) at_distance (size * 2) where (each.current_edge = self.current_edge);
		//		write ww;
		if (length(rr) > 0 and length(ww) < 1) {
		//							write rr;
			water w <- self;
			//			write length(rr);
			ask (rr) {
			//				write self;
				create water {
					myRiver <- myself;
					//					if (flip(0.5)) {
					location <- myself.shape.points closest_to w.location;
					target <- myself.shape.points farthest_to w.location;
					//						location<-first(myself.shape.points);
					//						target<-last(myself.shape.points);
					//					} else {
					////						location <- myself.shape.points farthest_to w.location;
					////						target <- myself.shape.points closest_to w.location;
					//						location<-last(myself.shape.points);
					//						target<-first(myself.shape.points);
					//					}
					//						location <- any_location_in(myself);
					//						target <- flip(0.9) ? any_location_in(dest) : any_location_in(myself);
					//					location <- (myRiver.shape.points closest_to source.location);
					//					target <- (myRiver.shape.points farthest_to source.location);
				}

			}

			//			flag <- 0;
		}

	}

	reflex movement {
	//		flag <- flag + 1;
		do goto on: the_graph target: target speed: sp;
		//		if (target != nil and location distance_to target <= sp) {
		//				location <- any_location_in(any(River));
		//			target <- any_location_in(any(River));
		if (location = target) {
			do die;
			//			target <- any_location_in(one_of(River));
		}

	}

}

species people skills: [moving] {
	float size <- 0.0015;
	float sp <- 0.0005;
	geometry b <- circle(1);
	geometry shape <- circle(size);
	float range <- size * 2;
	int repulsion_strength min: 1 <- 5;
	point t;

	reflex ss {
	//	do goto target:t on:b speed:sp ;
	//	if(location=t){		
	//			t<-b.points farthest_to location;
	//	}
	//people close <- one_of ( ( (self neighbors_at range) of_species people) sort_by (self distance_to each) );
	//		if close != nil {
	//			heading <- (self towards close) - 180;
	//			float dist <- self distance_to close;
	//			do move bounds:b speed:  dist / repulsion_strength heading: heading;
	//		}
		do wander bounds: b speed: sp;
	}

	aspect default {
		draw shape color: color;
	}

}

species River_region {
	float rrr <- ((1 + rnd(3)) / 1000);
	rgb color <- rnd_color(255);

	aspect default {
		draw shape color: #cyan; //rnd_color(255)  ;
		//		draw shape + rrr color: color;
		//		draw ""+shape.area*10000 at:first(shape.points);
	}

}

species River {
	float rrr <- ((1 + rnd(3)) / 1000);
	rgb color <- rnd_color(255);

	reflex ss {
	//		write River where (each touches self);
	}

	aspect default {
		draw shape color: #blue; //rnd_color(255)  ;
		//				draw shape+rrr color:color  ;
	}

}

species Station {
	list<float> heso <- [];
	string Name;
	int ll <- 0;
	geometry shape <- rectangle(0.005, 0.005);

	reflex ss {
		list vv <- water at_distance 0.05;
		ll <- length(vv);
		if (ll > 0) { 
			(vv[0]).color <- #green;
		}

	}

	aspect default {
		draw rectangle(0.005, 0.005) color: #red;
		draw circle(0.009) color: #red empty: true;
		draw Name + " " + heso[cycle mod 4388] + " " + ll size: 10 at: location - 0.02;
	}

}

experiment "main" type: gui {
	output {
		display "s" type: opengl {
			species River_region aspect: default;
			species people aspect: default;
			species River aspect: default;
			species water;
			species Station aspect: default;
		}

	}

}