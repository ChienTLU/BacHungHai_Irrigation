/***
* Name: BHH
* Author: hqngh
* Description: 
* Tags: Tag1, Tag2, TagN
***/
model BHH

global {
	file system_region_shapefile <- file("../includes/BHHSystem_region.shp");
	file river_region_shapefile <- file("../includes/SongBHH_region.shp");
	file river_shapefile <- file("../includes/river_simple1.shp");
	file tram_mua_shapefile <- file("../includes/TramMua.shp");
	file MN_10Cong_20152017 <- csv_file("../includes/MN_10Cong_20152017.csv", ",");
	//	geometry shape<-envelope(tram_mua_shapefile);	//1 7 13 19
	geometry shape <- envelope(river_shapefile); //1 7 13 19
	graph the_graph;
	list ss <- ["C.Xuan Quan", "BÁO ĐÁP", "Kenh Cau", "CẦU CẤT", "LỰC ĐIỀN", "Cong Neo", "Cong Tranh", "C.Ba Thuy", "C.Cau Xe", "C.An Tho"];
	list<list<int>>
	obs_ <- [[0, 160, 220, -20, 40], [0, 220, 280, 50, 110], [0, 170, 280, 20, 90], [0, 220, 280, 50, 110], [0, 140, 200, 0, 60], [0, 140, 190, -100, -30], [0, 120, 170, -50, 10], [0, 0, 0, 0, 0], [0, 0, 0, 0, 0], [0, 0, 0, 0, 0]];
	Station source;
	Station dest;
	matrix<float, float> data <- matrix<float>(matrix(MN_10Cong_20152017));
	bool close_lake;

	init {
		create System_region from: system_region_shapefile;
		create River_region from: river_region_shapefile;
		create River from: river_shapefile;
		//		write tram_mua_shapefile.contents;
		create Station from: tram_mua_shapefile {
			pa <- obs_[int(self)];
			heading <- float(pa[0]);
			TL_area <- (cone(heading + pa[1], heading + pa[2]) intersection world.shape) intersection circle(perception_distance);
			HL_area <- (cone(heading + pa[3], heading + pa[4]) intersection world.shape) intersection circle(perception_distance);
		}

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

		source <- first(Station where (each.Name = "Song Hong"));
		dest <- first(Station where (each.Name = "Song Thai Binh"));
		the_graph <- as_edge_graph(list(River));
		//		the_graph <- the_graph with_optimizer_type "NBAStarApprox";
		//		do regen;

		//		create people number: 1650 {
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
	//		geometry shape <- circle(size);
	//	geometry shape <- rectangle(size * 2, size * 0.5);
	geometry shape <- triangle(size);
	//	int flag <- 0;
	aspect default {
		draw shape color: color rotate: heading + 90;
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
		if (target != nil and location distance_to target <= sp) {
		//				location <- any_location_in(any(River));
		//			target <- any_location_in(any(River));
		//		if (location = target) {
			do die;
			//			target <- any_location_in(one_of(River));
		}

	}

}

species people skills: [moving] {
	float size <- 0.0015;
	float sp <- 0.001;
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
		do move bounds: b heading: self towards t speed: sp;
		if (location = t) {
			t <- b.points farthest_to location;
		}

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

species System_region {
	float rrr <- ((1 + rnd(3)) / 1000);
	rgb color <- rnd_color(255);

	reflex ss {
	//		write River where (each touches self);
	}

	aspect default {
		draw shape color: rgb(192, 192, 192, 255); //rnd_color(255)  ;
		//				draw shape+rrr color:color  ;
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

species Station skills: [moving] {
	rgb color <- rnd_color(255);
	list<float> heso <- [];
	float hh <- 0.0;
	float rad <- 0.01;
	string Name;
	int ll <- 0;
	geometry shape <- rectangle(0.005, 0.0025);
	float perception_distance <- rad;
	geometry TL_area;
	geometry HL_area;
	float TL_level<-0.0;
	float HL_level<-0.0;
	list<int> pa;

	reflex ss {
		if (length(heso) > 0) {
			hh <- heso[cycle mod 4388];
		}

		list<water> vv <- water at_distance (rad);
		ll <- length(vv);
		if (ll > 0 and self != source and self != dest) {
			(vv[0]).color <- #green;
			if (close_lake) {
				ask vv {
					do die;
//					point tmp <- target;
//					target <- location;
//					location <- tmp;
				}

			}

		} 
		TL_level<-TL_level+length(vv overlapping TL_area);
		HL_level<-HL_level+length(vv overlapping HL_area); 

	}
 

	aspect default {
		draw shape color: #red;
		draw circle(rad) color: #red empty: true;
		draw Name + " " + heso[cycle mod 4388] + " " + TL_level+ " " + HL_level size: 10 at: location + 0.002;
		if (TL_area != nil) {
			draw TL_area color: #green;
		}

		if (HL_area != nil) {
			draw HL_area color: #green;
		}

	}

}

experiment "main" type: gui {
	parameter "Fermer bord lac" var: close_lake <- false category: "Urban planning";
	output {
		display "s" type: opengl {
			species System_region aspect: default;
			species River_region aspect: default;
			species people aspect: default;
			species Station aspect: default;
			species River aspect: default;
			species water;
		}
		//		display "c"{
		//			
		//			chart "Observed" type: series background: #white {
		////				data 'S' value: first(agent_with_SIR_dynamic).S color: #green ;	
		//				loop s over:Station{
		//					data ''+s.Name value: s.hh color: s.color marker:false ;	
		//				}
		//			}
		//		}
		//		display "c2"{
		//			
		//			chart "Simulated" type: series background: #white {
		////				data 'S' value: first(agent_with_SIR_dynamic).S color: #green ;	
		//				loop s over:Station{
		//					data ''+s.Name value: s.ll color: s.color marker:false ;	
		//				}
		//			}
		//		}

	}

}