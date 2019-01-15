function generate_benderssub(; prob=prob[1], Crude_yield_data = Crude_yield_data[:,:,1], Desulphurisation_cost=Desulphurisation_cost[:,1], Sulphur_2=[:,1], Sulphur_GO_data= Sulphur_GO_data[:,1])
	
	model = Model(solver=CplexSolver(CPX_PARAM_SCRIND=0))
	@variable(model, pickCrude[c in crudes], Bin)

	@variable(model, 0<=crudeQuantity[c in crudes]<=Crude_upper_bound[c])
	@variable(model, slack1[c in crudes]>=0)
	@variable(model, slack2[c in crudes]>=0)
	@variable(model, Reformer95_lower<=flow_Reformer95<=Reformer_capacity)
	@variable(model, 0<=flow_Reformer100<=Reformer_capacity - Reformer95_lower)
	@variable(model, 0<=flow_Cracker_Mogas<=Cracker_capacity)
	@variable(model, 0<=flow_Cracker_AGO<=Cracker_capacity)
	@variable(model, 0<=flow_Isomerisation<=CDU_capacity)
	@variable(model, 0<=flow_Desulphurisation_CGO<=Cracker_capacity)
	@variable(model, 0<=flow_LG_producing<=CDU_capacity)
	@variable(model, 0<=flow_LN_producing<=CDU_capacity)
	@variable(model, 0<=flow_HF_2<=Cracker_capacity)
	@variable(model, 0<=volume_PG98<=CDU_capacity/Density_PG98_input[1])
	@variable(model, 0<=volume_ES95<=CDU_capacity/Density_PG98_input[1])
	@variable(model, 0<=volume_HF<=CDU_capacity/GO_density[7])

	@variable(model, 0<=blin_CDU_LG[k in LG_out]<=CDU_capacity)
	@variable(model, 0<=blin_Reformer95_LG[k in LG_out]<=CDU_capacity)
	@variable(model, 0<=blin_Reformer100_LG[k in LG_out]<=CDU_capacity)
	@variable(model, 0<=blin_Mogas_LG[k in LG_out]<=CDU_capacity)
	@variable(model, 0<=blin_AGO_LG[k in LG_out]<=CDU_capacity)
	@variable(model, 0<=blin_Cracker_Mogas[k in Cr_CGO]<=Cracker_capacity)
	@variable(model, 0<=blin_Cracker_AGO[k in Cr_CGO]<=Cracker_capacity)

	@variable(model, 0<=flow_Desulphurisation_1[c in crudes]<=Desulphurisation_capacity)
	@variable(model, 0<=flow_AGO_1[c in crudes]<=Crude_upper_bound[c])
	@variable(model, 0<=flow_AGO_2[c in crudes]<=Desulphurisation_capacity)
	@variable(model, 0<=flow_HF_1[c in crudes]<=Crude_upper_bound[c])
	@variable(model, 0<=flow_HF_3[c in crudes]<=Crude_upper_bound[c])
	@variable(model, 0<=flow_Burn[k in Burn]<=CDU_capacity)
	@variable(model, 0<=flow_PG98[k in PG98_in]<=CDU_capacity)
	@variable(model, 0<=flow_ES95[k in PG98_in]<=CDU_capacity)
	@variable(model, 0<=flow_AGO_3[k in AGO_in]<=Cracker_capacity)
	setupperbound(flow_AGO_3[1], CDU_capacity)
	@variable(model, 0<=flow_JPF[k in JPF_out]<=CDU_capacity)
	@variable(model, 0<=flow_Import[p in products]<=Import_upper[p])
	@variable(model, 0<=fraction_LG[k in LG_in]<=1)
	@variable(model, 0<=fraction_CGO[k in Cr_mode]<=1)











	@constraint(model, Desulphurisation_capacity_bound, flow_Desulphurisation_CGO + sum(flow_Desulphurisation_1[c] for c in crudes) <= Desulphurisation_capacity)


	@constraint(model, Mass_balance1, Reformer_fraction[1,1]*flow_Reformer95 +
						Reformer_fraction[2,1]*flow_Reformer100 +
						Cracker_fraction[1,1]*flow_Cracker_Mogas +
						Cracker_fraction[2,1]*flow_Cracker_AGO +
						Isomerisation_fraction[1]*flow_Isomerisation +
						Desulphurisation_fraction2[2]*flow_Desulphurisation_CGO -
						flow_Burn[1] +
						sum(
							Crude_yield_data[c,1]*(crudeQuantity[c] + slack1[c] - slack2[c]) +
							Desulphurisation_fraction[c,2]*flow_Desulphurisation_1[c]  for c in crudes
						) == 0)


	@constraint(model, Mass_balance2, Reformer_fraction[1,2]*flow_Reformer95 +
						Reformer_fraction[2,2]*flow_Reformer100 +
						Cracker_fraction[1,2]*flow_Cracker_Mogas +
						Cracker_fraction[2,2]*flow_Cracker_AGO -
						flow_LG_producing - flow_PG98[1] -
						flow_ES95[1] - flow_Burn[2] +
						sum(
							Crude_yield_data[c,2]*(crudeQuantity[c] + slack1[c] - slack2[c]) for c in crudes
						) == 0)


	@constraint(model, Mass_balance3, -flow_LN_producing - flow_Burn[3] -
						flow_PG98[3] - flow_ES95[3] -
						flow_Isomerisation - flow_JPF[1]*JPF_fraction[1,1] -
						flow_JPF[2]*JPF_fraction[1,2] +
						sum(
							Crude_yield_data[c,3]*(crudeQuantity[c]+slack1[c] - slack2[c]) for c in crudes
						) == 0)


	@constraint(model, Mass_balance4, -flow_JPF[1]*JPF_fraction[2,1] -
						flow_JPF[2]*JPF_fraction[2,2] -
						flow_Reformer95 - flow_Reformer100 +
						sum(
							Crude_yield_data[c,4]*(crudeQuantity[c]+slack1[c] - slack2[c]) for c in crudes
						) == 0)


	@constraint(model, Mass_balance5, -flow_JPF[1]*JPF_fraction[3,1] -
						flow_JPF[2]*JPF_fraction[3,2] -
						flow_AGO_3[1] +
						sum(
							Crude_yield_data[c,5]*(crudeQuantity[c]+slack1[c] - slack2[c]) for c in crudes
						) == 0)


	@constraint(model, Mass_balance7, -flow_Cracker_Mogas - flow_Cracker_AGO +
						sum(
							Crude_yield_data[c,7]*(crudeQuantity[c]+slack1[c] - slack2[c]) for c in crudes
						) == 0)


	@constraint(model, GO_balance[c in crudes], -flow_AGO_1[c] - flow_Desulphurisation_1[c] - flow_HF_3[c] +
						Crude_yield_data[c,6]*(crudeQuantity[c]+slack1[c] - slack2[c]) == 0)


	@constraint(model, VR_balance[c in crudes], 	Crude_yield_data[c,8]*(crudeQuantity[c]+slack1[c] - slack2[c]) == flow_HF_1[c])


	@constraint(model, Desulphurisation_balance[c in crudes], Desulphurisation_fraction[c,1]*flow_Desulphurisation_1[c] == flow_AGO_2[c])


	@constraint(model, Reformer95_balance, 	flow_Reformer95*Reformer_fraction[1,3] +
								flow_Reformer100*Reformer_fraction[2,3] ==
								flow_PG98[4] + flow_ES95[4])


	@constraint(model, Reformer100_balance, 	flow_Reformer95*Reformer_fraction[1,4] +
								flow_Reformer100*Reformer_fraction[2,4] ==
								flow_PG98[5] + flow_ES95[5])


	@constraint(model, Isomerisation_balance, flow_Isomerisation*Isomerisation_fraction[2] ==
								flow_PG98[2] + flow_ES95[2])


	@constraint(model, CN_balance, 	flow_Cracker_Mogas*Cracker_fraction[1,3] +
						flow_Cracker_AGO*Cracker_fraction[2,3] ==
						flow_PG98[6] + flow_ES95[6])


	@constraint(model, CGO_balance, 	flow_Cracker_Mogas*Cracker_fraction[1,4] +
						flow_Cracker_AGO*Cracker_fraction[2,4] ==
						flow_Desulphurisation_CGO + flow_HF_2 + flow_AGO_3[2])


	@constraint(model, Desulphurisation_CGO_balance, Desulphurisation_fraction2[1]*flow_Desulphurisation_CGO == flow_AGO_3[3])


	@constraint(model, Demand_constraint1, flow_Import[1] + sum(flow_PG98[k] for k in PG98_in) >= Demand_quantity[1])


	@constraint(model, Demand_constraint2, flow_Import[2] + sum(flow_ES95[k] for k in PG98_in) >= Demand_quantity[2])


	@constraint(model, Demand_constraint3, flow_Import[3] + sum(flow_JPF[k] for k in JPF_out) >= Demand_quantity[3])


	@constraint(model, Demand_constraint4, flow_Import[4] + sum(flow_AGO_3[k] for k in AGO_in) +
								sum(flow_AGO_1[c] + flow_AGO_2[c] for c in crudes) >= Demand_quantity[4])


	@constraint(model, Demand_constraint5, flow_Import[5] + flow_HF_2 + 
								sum(flow_HF_1[c] + flow_HF_3[c] for c in crudes) >= Demand_quantity[5])


	@constraint(model, Demand_constraint6, flow_Import[6] + flow_LG_producing >= Demand_quantity[6])


	@constraint(model, Demand_constraint7, flow_Import[7] + flow_LN_producing >= Demand_quantity[7])


	@constraint(model, PG98_volume_def,	flow_Import[1]/Density_products[1] +
							sum(flow_PG98[k]/Density_PG98_input[k] for k in PG98_in) == volume_PG98)


	@constraint(model, ES95_volume_def,	flow_Import[2]/Density_products[2] +
							sum(flow_ES95[k]/Density_PG98_input[k] for k in PG98_in) == volume_ES95)


	@constraint(model, Butane95_constraint,	flow_ES95[1]/Density_PG98_input[1] +
								0.03*flow_Import[2]/Density_products[2] <= 0.05*volume_ES95)


	@constraint(model, Butane98_constraint,	flow_PG98[1]/Density_PG98_input[1] +
								0.03*flow_Import[1]/Density_products[2] <= 0.05*volume_PG98)


	


	@constraint(model, LG_balance, 	sum(blin_CDU_LG[k] for k in LG_out) ==
						sum(
							Crude_yield_data[c,2]*(crudeQuantity[c]+slack1[c] - slack2[c])
						for c in crudes))


	@constraint(model, Reformer95_LG_balance, flow_Reformer95*Reformer_fraction[1,2] ==
								sum(blin_Reformer95_LG[k] for k in LG_out))


	@constraint(model, Reformer100_LG_balance, 	flow_Reformer100*Reformer_fraction[2,2] ==
									sum(blin_Reformer100_LG[k] for k in LG_out))


	@constraint(model, Cracker_Mogas_LG_balance, 	flow_Cracker_Mogas*Cracker_fraction[1,2] ==
									sum(blin_Mogas_LG[k] for k in LG_out))


	@constraint(model, Cracker_AGO_LG_balance, 	flow_Cracker_AGO*Cracker_fraction[2,2] ==
									sum(blin_AGO_LG[k] for k in LG_out))


	@constraint(model, pq_ES95_constraint, 	blin_CDU_LG[1] + blin_Reformer95_LG[1] +
								blin_Reformer100_LG[1] + blin_Mogas_LG[1] +
								blin_AGO_LG[1] == flow_ES95[1])


	@constraint(model, pq_PG98_constraint, 	blin_CDU_LG[2] + blin_Reformer95_LG[2] +
								blin_Reformer100_LG[2] + blin_Mogas_LG[2] +
								blin_AGO_LG[2] == flow_PG98[1])


	@constraint(model, pq_burn_constraint, 	blin_CDU_LG[3] + blin_Reformer95_LG[3] +
								blin_Reformer100_LG[3] + blin_Mogas_LG[3] +
								blin_AGO_LG[3] == flow_Burn[2])


	@constraint(model, pq_demand_constraint, 	blin_CDU_LG[4] + blin_Reformer95_LG[4] +
								blin_Reformer100_LG[4] + blin_Mogas_LG[4] +
								blin_AGO_LG[4] == flow_LG_producing)


	@constraint(model, LG_split_balance, sum(fraction_LG[k] for k in LG_in) == 1)


	@constraint(model, VP_ES95_lower, -0.45*volume_ES95 + flow_Import[2]*Product_VP[2]/Density_products[2] +
						sum(VP[k]*flow_ES95[k]/Density_PG98_input[k] for k in PG98_in) +
						LG_parameters[1,1]*blin_CDU_LG[1]/Density_PG98_input[1] +
						LG_parameters[1,2]*blin_Reformer95_LG[1]/Density_PG98_input[1] +
						LG_parameters[1,3]*blin_Reformer100_LG[1]/Density_PG98_input[1] +
						LG_parameters[1,4]*blin_Mogas_LG[1]/Density_PG98_input[1] +
						LG_parameters[1,5]*blin_AGO_LG[1]/Density_PG98_input[1] >= 0)


	@constraint(model, VP_ES95_upper, -0.80*volume_ES95 + flow_Import[2]*Product_VP[2]/Density_products[2] +
						sum(VP[k]*flow_ES95[k]/Density_PG98_input[k] for k in PG98_in) +
						LG_parameters[1,1]*blin_CDU_LG[1]/Density_PG98_input[1] +
						LG_parameters[1,2]*blin_Reformer95_LG[1]/Density_PG98_input[1] +
						LG_parameters[1,3]*blin_Reformer100_LG[1]/Density_PG98_input[1] +
						LG_parameters[1,4]*blin_Mogas_LG[1]/Density_PG98_input[1] +
						LG_parameters[1,5]*blin_AGO_LG[1]/Density_PG98_input[1] <= 0)


	@constraint(model, VP_PG98_lower, -0.50*volume_PG98 + flow_Import[1]*Product_VP[1]/Density_products[1] +
						sum(VP[k]*flow_PG98[k]/Density_PG98_input[k] for k in PG98_in) +
						LG_parameters[1,1]*blin_CDU_LG[2]/Density_PG98_input[1] +
						LG_parameters[1,2]*blin_Reformer95_LG[2]/Density_PG98_input[1] +
						LG_parameters[1,3]*blin_Reformer100_LG[2]/Density_PG98_input[1] +
						LG_parameters[1,4]*blin_Mogas_LG[2]/Density_PG98_input[1] +
						LG_parameters[1,5]*blin_AGO_LG[2]/Density_PG98_input[1] >= 0)


	@constraint(model, VP_PG98_upper, -0.86*volume_PG98 + flow_Import[1]*Product_VP[1]/Density_products[1] +
						sum(VP[k]*flow_PG98[k]/Density_PG98_input[k] for k in PG98_in) +
						LG_parameters[1,1]*blin_CDU_LG[2]/Density_PG98_input[1] +
						LG_parameters[1,2]*blin_Reformer95_LG[2]/Density_PG98_input[1] +
						LG_parameters[1,3]*blin_Reformer100_LG[2]/Density_PG98_input[1] +
						LG_parameters[1,4]*blin_Mogas_LG[2]/Density_PG98_input[1] +
						LG_parameters[1,5]*blin_AGO_LG[2]/Density_PG98_input[1] <= 0)


	@constraint(model, RON_PG98, 	-98*volume_PG98 + flow_Import[1]*Product_RON[1]/Density_products[1] +
					sum( RON[k]*flow_PG98[k]/Density_PG98_input[k] for k in PG98_in) +
					LG_parameters[2,1]*blin_CDU_LG[2]/Density_PG98_input[1] +
					LG_parameters[2,2]*blin_Reformer95_LG[2]/Density_PG98_input[1] +
					LG_parameters[2,3]*blin_Reformer100_LG[2]/Density_PG98_input[1] +
					LG_parameters[2,4]*blin_Mogas_LG[2]/Density_PG98_input[1] +
					LG_parameters[2,5]*blin_AGO_LG[2]/Density_PG98_input[1] >= 0)


	@constraint(model, RON_ES95, 	-95*volume_ES95 + flow_Import[2]*Product_RON[2]/Density_products[2] +
					sum(RON[k]*flow_ES95[k]/Density_PG98_input[k] for k in PG98_in) +
					LG_parameters[2,1]*blin_CDU_LG[1]/Density_PG98_input[1] +
					LG_parameters[2,2]*blin_Reformer95_LG[1]/Density_PG98_input[1] +
					LG_parameters[2,3]*blin_Reformer100_LG[1]/Density_PG98_input[1] +
					LG_parameters[2,4]*blin_Mogas_LG[1]/Density_PG98_input[1] +
					LG_parameters[2,5]*blin_AGO_LG[1]/Density_PG98_input[1] >= 0)


	@constraint(model, Sensitivity_PG98, 	-10*volume_PG98 + flow_Import[1]*(Product_RON[1] - Product_MON[1])/Density_products[1] +
							sum((RON[k] - MON[k])*flow_PG98[k]/Density_PG98_input[k] for k in PG98_in) +
							(LG_parameters[2,1] - LG_parameters[3,1])*blin_CDU_LG[2]/Density_PG98_input[1] +
							(LG_parameters[2,2] - LG_parameters[3,2])*blin_Reformer95_LG[2]/Density_PG98_input[1] +
							(LG_parameters[2,3] - LG_parameters[3,3])*blin_Reformer100_LG[2]/Density_PG98_input[1] +
							(LG_parameters[2,4] - LG_parameters[3,4])*blin_Mogas_LG[2]/Density_PG98_input[1] +
							(LG_parameters[2,5] - LG_parameters[3,5])*blin_AGO_LG[2]/Density_PG98_input[1] <= 0)


	@constraint(model, Sensitivity_ES95, 	-10*volume_ES95 + flow_Import[2]*(Product_RON[2] - Product_MON[2])/Density_products[2] +
							sum((RON[k] - MON[k])*flow_ES95[k]/Density_PG98_input[k] for k in PG98_in) +
							(LG_parameters[2,1] - LG_parameters[3,1])*blin_CDU_LG[1]/Density_PG98_input[1] +
							(LG_parameters[2,2] - LG_parameters[3,2])*blin_Reformer95_LG[1]/Density_PG98_input[1] +
							(LG_parameters[2,3] - LG_parameters[3,3])*blin_Reformer100_LG[1]/Density_PG98_input[1] +
							(LG_parameters[2,4] - LG_parameters[3,4])*blin_Mogas_LG[1]/Density_PG98_input[1] +
							(LG_parameters[2,5] - LG_parameters[3,5])*blin_AGO_LG[1]/Density_PG98_input[1] <= 0)



	@constraint(model, Cracker_Mogas_CGO_balance, blin_Cracker_Mogas[1] + blin_Cracker_Mogas[2] +
									blin_Cracker_Mogas[3] == flow_Cracker_Mogas*Cracker_fraction[1,4])


	@constraint(model, Cracker_AGO_CGO_balance, 	blin_Cracker_AGO[1] + blin_Cracker_AGO[2] +
									blin_Cracker_AGO[3] == flow_Cracker_AGO*Cracker_fraction[2,4])


	@constraint(model, CGO_split_balance, sum(fraction_CGO[k] for k in Cr_mode) == 1)


	@constraint(model, pq_AGO_constraint, blin_Cracker_Mogas[1] + blin_Cracker_AGO[1] == flow_AGO_3[2])


	@constraint(model, pq_HF_constraint, blin_Cracker_Mogas[2] + blin_Cracker_AGO[2] == flow_HF_2)


	@constraint(model, pq_Desulphurisation_constraint, blin_Cracker_Mogas[3] + blin_Cracker_AGO[3] == flow_Desulphurisation_CGO)


	@constraint(model, HF_volume_def, -volume_HF + flow_Import[5]/Density_products[5] +
						flow_HF_2/CGO_density +
						sum(flow_HF_1[c]/HFO_density[c] + flow_HF_3[c]/GO_density[c] for c in crudes) == 0)


	@constraint(model, HF_viscosity_lower, 	flow_Import[5]*Viscosity_products[5]/Density_products[5] +
								sum(
									flow_HF_1[c]*Viscosity_HF1[c]/HFO_density[c] +
									flow_HF_3[c]*Viscosity_HF3[c]/GO_density[c] for c in crudes
								) +
								(blin_Cracker_Mogas[2]*Mogas_viscosity + blin_Cracker_AGO[2]*AGO_viscosity)/CGO_density -
								30*volume_HF >= 0)


	@constraint(model, HF_viscosity_upper, 	flow_Import[5]*Viscosity_products[5]/Density_products[5] +
								sum(
									flow_HF_1[c]*Viscosity_HF1[c]/HFO_density[c] +
									flow_HF_3[c]*Viscosity_HF3[c]/GO_density[c] for c in crudes
								) +
								(blin_Cracker_Mogas[2]*Mogas_viscosity + blin_Cracker_AGO[2]*AGO_viscosity)/CGO_density -
								33*volume_HF <= 0)


	@constraint(model, AGO_sulphur_balance, 	flow_Import[4]*Product_Sulphur[4] - Sulphur_spec*flow_Import[4] +
							sum((Sulphur_GO_data[c] - Sulphur_spec) * flow_AGO_1[c] + (Sulphur_2[c] - Sulphur_spec)*flow_AGO_2[c] for c in crudes) +								
								flow_AGO_3[1]*(Sulphur_3[1] - Sulphur_spec) +
								blin_Cracker_AGO[1]*(AGO_Sulphur - Sulphur_spec) +
								blin_Cracker_Mogas[1]*(Mogas_Sulphur - Sulphur_spec) +
								blin_Cracker_AGO[3]*AGO_Sulphur*0.005 +
								blin_Cracker_Mogas[3]*Mogas_Sulphur*0.005 -
								Sulphur_spec*flow_AGO_3[3] <= 0)


	@constraint(model, Refinery_Fuel, 1.3*flow_Burn[1] + 1.2*flow_Burn[2] + 1.1*flow_Burn[3] -
						flow_Reformer95*Reformer_fraction[1,5] -
						flow_Reformer100*Reformer_fraction[2,5] -
						flow_Cracker_Mogas*Cracker_fraction[1,5] -
						flow_Cracker_AGO*Cracker_fraction[2,5] -
						flow_Isomerisation*Isomerisation_fraction[3] -
						flow_Desulphurisation_CGO*Desulphurisation_fraction2[3] - 15.2 -
						sum(
							0.018*(crudeQuantity[c]+slack1[c] - slack2[c]) +
							flow_Desulphurisation_1[c]*Desulphurisation_fraction[c,3] for c in crudes
						) >= 0)


	@constraint(model, Cracker_capacity_bound, flow_Cracker_Mogas + flow_Cracker_AGO <= Cracker_capacity)


	@constraint(model, Reformer_capacity_bound, flow_Reformer95 + flow_Reformer100 <= Reformer_capacity)

    #add convex relaxations
    npoints = 5
    add_McCormick(m, fraction_LG[1], flow_ES95[1], blin_CDU_LG[1])
    add_McCormick(m, fraction_LG[1],flow_PG98[1], blin_CDU_LG[2] )
    add_McCormick(m,  fraction_LG[1],flow_Burn[2], blin_CDU_LG[3] )
    add_McCormick(m,  fraction_LG[1],flow_LG_producing, blin_CDU_LG[4] )
    add_McCormick(m,  fraction_LG[2],flow_ES95[1], blin_Reformer95_LG[1] )
    add_McCormick(m,  fraction_LG[2],flow_PG98[1], blin_Reformer95_LG[2] )
    add_McCormick(m,  fraction_LG[2],flow_Burn[2], blin_Reformer95_LG[3] )
    add_McCormick(m,  fraction_LG[2],flow_LG_producing, blin_Reformer95_LG[4] )
    add_McCormick(m,  fraction_LG[3],flow_ES95[1], blin_Reformer100_LG[1] )
    add_McCormick(m,  fraction_LG[3],flow_PG98[1], blin_Reformer100_LG[2] )
    add_McCormick(m,  fraction_LG[3],flow_Burn[2], blin_Reformer100_LG[3] )
    add_McCormick(m,  fraction_LG[3],flow_LG_producing, blin_Reformer100_LG[4] )
    add_McCormick(m,  fraction_LG[4],flow_ES95[1], blin_Mogas_LG[1] )
    add_McCormick(m,  fraction_LG[4],flow_PG98[1], blin_Mogas_LG[2] )
    add_McCormick(m,  fraction_LG[4],flow_Burn[2], blin_Mogas_LG[3] )
    add_McCormick(m,  fraction_LG[4],flow_LG_producing, blin_Mogas_LG[4] )
    add_McCormick(m,  fraction_LG[5],flow_ES95[1], blin_AGO_LG[1] )
    add_McCormick(m,  fraction_LG[5],flow_PG98[1], blin_AGO_LG[2] )
    add_McCormick(m,  fraction_LG[5],flow_Burn[2], blin_AGO_LG[3] )
    add_McCormick(m,  fraction_LG[5],flow_LG_producing, blin_AGO_LG[4] )
    add_McCormick(m,  fraction_CGO[1],flow_AGO_3[2], blin_Cracker_Mogas[1] )
    add_McCormick(m,  fraction_CGO[1],flow_HF_2, blin_Cracker_Mogas[2] )
    add_McCormick(m,  fraction_CGO[1],flow_Desulphurisation_CGO, blin_Cracker_Mogas[3] )
    add_McCormick(m,  fraction_CGO[2],flow_AGO_3[2], blin_Cracker_AGO[1] )
    add_McCormick(m,  fraction_CGO[2],flow_HF_2, blin_Cracker_AGO[2] )
    add_McCormick(m,  fraction_CGO[2],flow_Desulphurisation_CGO, blin_Cracker_AGO[3] )


	# xmap = Dict()
	# add_PiecewiseMcCormick(model, fraction_LG[1], flow_ES95[1], blin_CDU_LG[1], npoints, xmap)
	# add_PiecewiseMcCormick(model, fraction_LG[1],flow_PG98[1], blin_CDU_LG[2] , npoints,xmap)
	# add_PiecewiseMcCormick(model,  fraction_LG[1],flow_Burn[2], blin_CDU_LG[3] , npoints,xmap)
	# add_PiecewiseMcCormick(model,  fraction_LG[1],flow_LG_producing, blin_CDU_LG[4] , npoints,xmap)
	# add_PiecewiseMcCormick(model,  fraction_LG[2],flow_ES95[1], blin_Reformer95_LG[1] , npoints,xmap)
	# add_PiecewiseMcCormick(model,  fraction_LG[2],flow_PG98[1], blin_Reformer95_LG[2] , npoints,xmap)
	# add_PiecewiseMcCormick(model,  fraction_LG[2],flow_Burn[2], blin_Reformer95_LG[3] , npoints,xmap)
	# add_PiecewiseMcCormick(model,  fraction_LG[2],flow_LG_producing, blin_Reformer95_LG[4] , npoints,xmap)
	# add_PiecewiseMcCormick(model,  fraction_LG[3],flow_ES95[1], blin_Reformer100_LG[1] , npoints,xmap)
	# add_PiecewiseMcCormick(model,  fraction_LG[3],flow_PG98[1], blin_Reformer100_LG[2] , npoints,xmap)
	# add_PiecewiseMcCormick(model,  fraction_LG[3],flow_Burn[2], blin_Reformer100_LG[3] , npoints,xmap)
	# add_PiecewiseMcCormick(model,  fraction_LG[3],flow_LG_producing, blin_Reformer100_LG[4] , npoints,xmap)
	# add_PiecewiseMcCormick(model,  fraction_LG[4],flow_ES95[1], blin_Mogas_LG[1] , npoints,xmap)
	# add_PiecewiseMcCormick(model,  fraction_LG[4],flow_PG98[1], blin_Mogas_LG[2] , npoints,xmap)
	# add_PiecewiseMcCormick(model,  fraction_LG[4],flow_Burn[2], blin_Mogas_LG[3] , npoints,xmap)
	# add_PiecewiseMcCormick(model,  fraction_LG[4],flow_LG_producing, blin_Mogas_LG[4] , npoints,xmap)
	# add_PiecewiseMcCormick(model,  fraction_LG[5],flow_ES95[1], blin_AGO_LG[1] , npoints,xmap)
	# add_PiecewiseMcCormick(model,  fraction_LG[5],flow_PG98[1], blin_AGO_LG[2] , npoints,xmap)
	# add_PiecewiseMcCormick(model,  fraction_LG[5],flow_Burn[2], blin_AGO_LG[3] , npoints,xmap)
	# add_PiecewiseMcCormick(model,  fraction_LG[5],flow_LG_producing, blin_AGO_LG[4] , npoints,xmap)
	# add_PiecewiseMcCormick(model,  fraction_CGO[1],flow_AGO_3[2], blin_Cracker_Mogas[1] , npoints,xmap)
	# add_PiecewiseMcCormick(model,  fraction_CGO[1],flow_HF_2, blin_Cracker_Mogas[2] , npoints,xmap)
	# add_PiecewiseMcCormick(model,  fraction_CGO[1],flow_Desulphurisation_CGO, blin_Cracker_Mogas[3] , npoints,xmap)
	# add_PiecewiseMcCormick(model,  fraction_CGO[2],flow_AGO_3[2], blin_Cracker_AGO[1] , npoints,xmap)
	# add_PiecewiseMcCormick(model,  fraction_CGO[2],flow_HF_2, blin_Cracker_AGO[2] , npoints,xmap)
	# add_PiecewiseMcCormick(model,  fraction_CGO[2],flow_Desulphurisation_CGO, blin_Cracker_AGO[3] , npoints,xmap)
	
	# add_LogPiecewiseMcCormick(model, fraction_LG[1], flow_ES95[1], blin_CDU_LG[1], npoints, xmap)
	# add_LogPiecewiseMcCormick(model, fraction_LG[1],flow_PG98[1], blin_CDU_LG[2] , npoints,xmap)
	# add_LogPiecewiseMcCormick(model,  fraction_LG[1],flow_Burn[2], blin_CDU_LG[3] , npoints,xmap)
	# add_LogPiecewiseMcCormick(model,  fraction_LG[1],flow_LG_producing, blin_CDU_LG[4] , npoints,xmap)
	# add_LogPiecewiseMcCormick(model,  fraction_LG[2],flow_ES95[1], blin_Reformer95_LG[1] , npoints,xmap)
	# add_LogPiecewiseMcCormick(model,  fraction_LG[2],flow_PG98[1], blin_Reformer95_LG[2] , npoints,xmap)
	# add_LogPiecewiseMcCormick(model,  fraction_LG[2],flow_Burn[2], blin_Reformer95_LG[3] , npoints,xmap)
	# add_LogPiecewiseMcCormick(model,  fraction_LG[2],flow_LG_producing, blin_Reformer95_LG[4] , npoints,xmap)
	# add_LogPiecewiseMcCormick(model,  fraction_LG[3],flow_ES95[1], blin_Reformer100_LG[1] , npoints,xmap)
	# add_LogPiecewiseMcCormick(model,  fraction_LG[3],flow_PG98[1], blin_Reformer100_LG[2] , npoints,xmap)
	# add_LogPiecewiseMcCormick(model,  fraction_LG[3],flow_Burn[2], blin_Reformer100_LG[3] , npoints,xmap)
	# add_LogPiecewiseMcCormick(model,  fraction_LG[3],flow_LG_producing, blin_Reformer100_LG[4] , npoints,xmap)
	# add_LogPiecewiseMcCormick(model,  fraction_LG[4],flow_ES95[1], blin_Mogas_LG[1] , npoints,xmap)
	# add_LogPiecewiseMcCormick(model,  fraction_LG[4],flow_PG98[1], blin_Mogas_LG[2] , npoints,xmap)
	# add_LogPiecewiseMcCormick(model,  fraction_LG[4],flow_Burn[2], blin_Mogas_LG[3] , npoints,xmap)
	# add_LogPiecewiseMcCormick(model,  fraction_LG[4],flow_LG_producing, blin_Mogas_LG[4] , npoints,xmap)
	# add_LogPiecewiseMcCormick(model,  fraction_LG[5],flow_ES95[1], blin_AGO_LG[1] , npoints,xmap)
	# add_LogPiecewiseMcCormick(model,  fraction_LG[5],flow_PG98[1], blin_AGO_LG[2] , npoints,xmap)
	# add_LogPiecewiseMcCormick(model,  fraction_LG[5],flow_Burn[2], blin_AGO_LG[3] , npoints,xmap)
	# add_LogPiecewiseMcCormick(model,  fraction_LG[5],flow_LG_producing, blin_AGO_LG[4] , npoints,xmap)
	# add_LogPiecewiseMcCormick(model,  fraction_CGO[1],flow_AGO_3[2], blin_Cracker_Mogas[1] , npoints,xmap)
	# add_LogPiecewiseMcCormick(model,  fraction_CGO[1],flow_HF_2, blin_Cracker_Mogas[2] , npoints,xmap)
	# add_LogPiecewiseMcCormick(model,  fraction_CGO[1],flow_Desulphurisation_CGO, blin_Cracker_Mogas[3] , npoints,xmap)
	# add_LogPiecewiseMcCormick(model,  fraction_CGO[2],flow_AGO_3[2], blin_Cracker_AGO[1] , npoints,xmap)
	# add_LogPiecewiseMcCormick(model,  fraction_CGO[2],flow_HF_2, blin_Cracker_AGO[2] , npoints,xmap)
	# add_LogPiecewiseMcCormick(model,  fraction_CGO[2],flow_Desulphurisation_CGO, blin_Cracker_AGO[3] , npoints,xmap)
   	@objective(model, Min, prob*(
								Cracker_Mogas_cost*flow_Cracker_Mogas +
								Cracker_AGO_cost*flow_Cracker_AGO +
								Reformer95_cost*flow_Reformer95 +
								Reformer100_cost*flow_Reformer100 +
								Isomerisation_cost*flow_Isomerisation +
								Desulphurisation_CGO_cost*flow_Desulphurisation_CGO -
								LG_sale*flow_LG_producing -
								LN_sale*flow_LN_producing -
								HF_sale*flow_HF_2 +
								sum(
									Desulphurisation_cost[c]*flow_Desulphurisation_1[c] -
									AGO_sale*flow_AGO_1[c] -
									AGO_sale*flow_AGO_2[c] -
									HF_sale*flow_HF_1[c] -
									HF_sale*flow_HF_3[c] +
									((100*slack1[c] + 100 *slack2[c])/1000)/BarrelToKT[c]*GranularityOfBarrels*(Crude_price[c]+1) for c in crudes
								) -
								sum(
									PG98_sale*flow_PG98[k] +
									ES95_sale*flow_ES95[k] for k in PG98_in
								) -
								sum(
									JET_sale*flow_JPF[k] for k in JPF_out
								) -
								sum(
									AGO_sale*flow_AGO_3[k] for k in AGO_in
								)
							) )

   	return model
end


