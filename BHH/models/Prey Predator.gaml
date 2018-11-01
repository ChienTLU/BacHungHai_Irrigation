/**
* Name: prey predator
* Author: HUYNH Quang Nghi
* Description: This is a simple comodel serve to demonstrate the mixing behaviors of preyPredator with the Ants. Ants are the prey, fleeing from Predators, when they are not chasing, they try to do job of the ants.
* Tags: comodel
*/
model prey_predator

global {
	geometry shape <- square(100);
	float perceipt_radius <- 3.0;
	int preyinit <- 100;
	int predatorinit <- 100;
//	float prey_energy_transfert <- 0.5;
//	float prey_energy_consum <- 0.0005;
//	int prey_nb_max_offsprings <- 5;
//	float prey_energy_reproduce <- 1.5;
//	float prey_proba_reproduce <- 0.005;
//	float predator_energy_transfert <- 0.5;
//	float predator_energy_consum <- 0.007;
//	int predator_nb_max_offsprings <- 5;
//	float predator_energy_reproduce <- 1.5;
//	float predator_proba_reproduce <- 0.01;
//	int num_to_be_attacker <- 3;


	float prey_energy_transfert <- 0.5;
	float prey_energy_consum <- 0.01;
	int prey_nb_max_offsprings <- 5;
	float prey_energy_reproduce <- 1.5;
	float prey_proba_reproduce <- 0.01;
	float predator_energy_transfert <- 0.5;
	float predator_energy_consum <- 0.01;
	int predator_nb_max_offsprings <- 5;
	float predator_energy_reproduce <- 1.5;
	float predator_proba_reproduce <- 0.01;
	int num_to_be_attacker <- 3;
	list<agent> lstPredator;
	list<agent> lstPrey;

	init {
		create prey number: preyinit;
		create predator number: predatorinit;
		lstPredator <- list<agent>(predator);
		lstPrey <- list<agent>(prey);
	}

	reflex regen_veg {
		create vegetal number: 1;
	}

}

species generic_species skills: [moving] {
	float speed <- 1.0;
	point goal <- nil;
	bool is_chased <- false;
	float max_energy;
	float max_transfert;
	float energy_consum;
	float proba_reproduce;
	float nb_max_offsprings;
	float energy_transfert;
	float energy_reproduce;
	float energy <- (rnd(1000) / 1000)   ;

	reflex reproduce when: (energy >= energy_reproduce)and (flip(proba_reproduce)) {
		int nb_offsprings <- int(1 + rnd(nb_max_offsprings - 1));
		create species(self) number: nb_offsprings {
			energy <- myself.energy / nb_offsprings;
		}

		energy <- energy / nb_offsprings - energy_reproduce;
	}

	reflex die when: energy <= 0 {
		do die ;
	}
	
	reflex live_with_my_goal {
//		write energy;
//		write energy_reproduce;
		if (goal != nil) { //			do wander speed: speed;
 do goto target: goal speed: speed;
		} else {
			do wander speed: speed;
		}
		energy<-energy-energy_consum;
	}

}

species prey parent: generic_species {
	geometry shape <- circle(0.5);
	float speed <- 0.2;
	rgb color <- #green;
	bool is_hunting <- false;
	float energy_transfert <- prey_energy_transfert;
	float energy_consum <- prey_energy_consum;
	float proba_reproduce <- prey_proba_reproduce;
	int nb_max_offsprings <- prey_nb_max_offsprings;
	float energy_reproduce <- prey_energy_reproduce;
	list<agent> victim;
	list<agent> boss;

	reflex which_victim_which_boss {
		list same <- prey at_distance (perceipt_radius * 5);
//		if (length(same) > num_to_be_attacker) {
		if (length(prey) > length(predator)) { 
			victim <- lstPredator;
			boss <- [];
		} else {
			victim <- list(vegetal);
			boss <- lstPredator;
		}

	}

	reflex hunting {
		if (goal = nil) {
			list tmp <- (victim where (!dead(each) and each.location distance_to self.location < perceipt_radius));
			if (length(tmp) > 0) {
				agent a <- first(tmp sort (each.shape distance_to self.shape));
				if (a = nil) {
					a <- any((victim where (!dead(each))));
				}

				if (a != nil) {
					speed <- 2.0;
					goal <- a.location;
					is_hunting <- true;
				}

			}

		} else if ((self.location distance_to goal < 0.5)) {
			ask victim where (!dead(each) and each.location distance_to goal < 0.5) { //				write ""+myself+" eat "+self;
				do die;
			}

			energy <- energy + energy_transfert;
			is_hunting <- false;
			goal <- nil;
			speed <- 1.0;
		}

	}

	//	reflex fleeing {
	//		if (!is_chased and !is_hunting) {
	//			goal <- nil;
	//		}
	//
	//		if (length((boss where (each != nil and !dead(each) and each distance_to self.location < perceipt_radius))) > 0) {
	//			speed <- 1.0;
	//			is_chased <- true;
	//			color <- #lime;
	//			if (goal = nil) {
	//				agent a <- any(((lstPrey where (each != nil and !dead(each) and !generic_species(each).is_chased))));
	//				if (a != nil and !dead(a)) {
	//					if (flip(0.5)) {
	//						goal <- a.location;
	//					} else {
	//						goal <- any_location_in(world.shape);
	//					}
	//
	//				} else {
	//					goal <- any_location_in(world.shape);
	//				}
	//
	//			}
	//
	//		}
	//
	//		if (is_chased and goal != nil and self.location distance_to goal < 0.5) {
	//			goal <- nil;
	//		}
	//
	//		if (length((boss where (each != nil and !dead(each))) where (each distance_to self <= perceipt_radius)) = 0) {
	//			is_chased <- false;
	//			color <- #green;
	//			speed <- 0.2;
	//		}
	//
	//	}
	aspect default { //		draw circle(perceipt_radius) color: #springgreen empty: true;
 draw shape color: color;
	}

}

species predator parent: generic_species {
	geometry shape <- triangle(1);
	rgb color <- #red;
	float energy_transfert <- predator_energy_transfert;
	float energy_consum <- predator_energy_consum;
	float proba_reproduce <- predator_proba_reproduce;
	int nb_max_offsprings <- predator_nb_max_offsprings;
	float energy_reproduce <- predator_energy_reproduce;
	bool is_hunting <- false;
	list<agent> victim;
	list<agent> boss;

	reflex which_victim_which_boss {
		list same <- predator at_distance (perceipt_radius * 5);
//		if (length(same) > num_to_be_attacker) { 
		if (length(predator) > length(prey)) { 
			victim <- lstPrey;
			boss <- [];
		} else {
			victim <- list(vegetal);
			boss <- lstPrey;
		}

	}

	reflex hunting {
		if (goal = nil) {
			list tmp <- (victim where (!dead(each) and each.location distance_to self.location < perceipt_radius));
			if (length(tmp) > 0) {
				agent a <- first(tmp sort (each.shape distance_to self.shape));
				if (a = nil) {
					a <- any((victim where (!dead(each))));
				}

				if (a != nil) {
					speed <- 2.0;
					goal <- a.location;
					is_hunting <- true;
				}

			}

		} else if ((self.location distance_to goal < 0.5)) {
			ask victim where (!dead(each) and each.location distance_to goal < 0.5) { //				write ""+myself+" eat "+self;
				do die;
			}

			energy <- energy + energy_transfert;
			goal <- nil;
			speed <- 1.0;
		}

	}
	//	reflex hunting {
 //		if (goal = nil) {
 //			list tmp <- ( victim where (!dead(each) and each.location distance_to self.location < perceipt_radius));

	//			if (length(tmp) > 0) {
 //				agent a <- first(tmp sort (each.shape distance_to self.shape));
 //				if (a = nil) {
 //					a <- any((victim where (!dead(each))));

	//				}
 //
 //				if (a != nil) {
 //					speed <- 2.0;
 //					goal <- a.location;
 //					is_hunting <- true;
 //				}
 //
 //			}
 //

	//		} else if ((self.location distance_to goal < 0.5)) {
 //			ask victim where (!dead(each) and each.location distance_to goal < 0.5) {
 //				do die;
 //			}
 //

	//			is_hunting <- false;
 //			goal <- nil;
 //			speed <- 1.0;
 //		}
 //
 //	}
 //	reflex fleeing {
 //		if (!is_chased and !is_hunting) {
 //			goal <- nil;
 //		}
 //

	//		if (length((boss where (each != nil and !dead(each) and each distance_to self.location < perceipt_radius))) > 0) {
 //			speed <- 1.0;
 //			is_chased <- true;

	//			color <- #lime;
 //			if (goal = nil) {
 //				agent a <- any(((lstPrey where (each != nil and !dead(each) and !generic_species(each).is_chased))));

	//				if (a != nil and !dead(a)) {
 //					if (flip(0.5)) {
 //						goal <- a.location;
 //					} else {
 //						goal <- any_location_in(world.shape);
 //					}
 //

	//				} else {
 //					goal <- any_location_in(world.shape);
 //				}
 //
 //			}
 //
 //		}
 //
 //		if (is_chased and goal != nil and self.location distance_to goal < 0.5) {

	//			goal <- nil;
 //		}
 //
 //		if (length((boss where (each != nil and !dead(each))) where (each distance_to self <= perceipt_radius)) = 0) {
 //			is_chased <- false;

	//			color <- #green;
 //			speed <- 0.2;
 //		}
 //
 //	}
	aspect default {
	//		draw circle(perceipt_radius * 3) color: #pink empty: true;
	//		draw circle(perceipt_radius) color: #pink empty: true; //		draw line(location,goal);
		draw shape color: color;
	}

}

species vegetal {
	geometry shape <- square(0.5);
	rgb color <- #blue;
	float maxFood <- 1.0;
	float foodProd <- (rnd(1000) / 1000) * 0.01;
	float food <- (rnd(1000) / 1000) max: maxFood update: food + foodProd;

	aspect default {
		draw shape color: color;
	}

}

experiment "Prey Predator Exp" type: gui { 
	output {
		display main_display {
			species vegetal;
			species prey;
			species predator;
		}

		display Population_information  {
			chart "Species evolution" type: series {
				data "number_of_preys" value: length(prey) color: #green marker:false;
				data "number_of_predator" value: length(predator) color: #red marker:false;
			}

		}

	}

}