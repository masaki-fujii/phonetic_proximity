cap ado uninstall ftools
cap ado uninstall reghdfe
cap ado uninstall ppmlhdfe

ssc install ftools
ssc install reghdfe
ssc install ppmlhdfe
ssc install outreg2
ssc install coefplot

clear all
ftools, compile

set more off

//set your directly here
cap cd "I:\My Drive\fujii\result"

use dataset, clear

cap mkdir table
cap mkdir figure

//Take the log of the dependent variables
gen ln_trade_comtrade = log(tradeflow_comtrade_o)
gen ln_trade_baci = log(tradeflow_baci)
gen ln_trade_imf = log(tradeflow_imf_o)
gen ln_dist = log(dist)
gen ln_fdi = log(fdi)

//Genarate iso3 numeric
egen iso3num_o = group(iso3_o)
egen iso3num_d = group(iso3_d)

//Generate decades variable
gen decades = 10 * floor(year/10)

//Replace negative FDI with 0 
replace fdi = 0 if fdi < 0

//Define labels
label variable year "Year"
label variable decades "Decades"

label variable tradeflow_comtrade_o "Trade (UN Comtrade)"
label variable tradeflow_baci "Trade (CEPII BACI)"
label variable tradeflow_imf_o "Trade (IMF DOTS)"
label variable ln_trade_comtrade "log Trade (UN Comtrade)"
label variable ln_trade_baci "log Trade (CEPII BACI)"
label variable ln_trade_imf "log Trade (IMF DOTS)"
label variable fdi "FDI"
label variable ln_fdi "log FDI"

label variable col "Common Official Language"
label variable csl "Common Spoken Language"
label variable cnl "Common Native Language"
label variable lp1 "Linguistic Proximity (Tree)"
label variable lpc "Linguistic Proximity (Phonetics)"

label variable dist "Distance"
label variable ln_dist "log Distance"
label variable contig "Contiguity"
label variable col_dep_ever "Ex Colonizer/Colony"
label variable comcol "Common Colonizer"
label variable comrelig "Common Religion"
label variable comleg_posttrans "Common Legal System"
label variable histwars "History of Wars"

//Variables list
global vars1 ""
global vars2 "col"
global vars3 "csl"
global vars4 "cnl"
global vars5 "lp1"
global vars6 "lpc"
global vars7 "lp1 lpc"
global vars8 "csl cnl lp1 lpc"
global vars9 "col csl cnl lp1 lpc"

global controls "ln_dist contig col_dep_ever comcol comrelig comleg_posttrans histwars"

//Conditions
global conditions1 if(year>=1998)&(year<=2007)
global conditions2 if(year>=1985)&(year<=2013)&(un_member_o==1)&(un_member_d==1)&(terrchange_o==0)&(terrchange_d==0)&(col1==0)&(fdi>0)

global title1 "Original"
global title2 "Refined"


//Histograms of dependent variables (UN, BACI and IMF)
/*
hist tradeflow_comtrade_o, name(un, replace)
hist tradeflow_baci, name(baci, replace)
hist tradeflow_imf_o, name(imf, replace)
graph combine un baci imf
graph export figure\hist_lntrade.png, replace
*/
hist ln_trade_comtrade, name(lun, replace)
hist ln_trade_baci, name(lbaci, replace)
hist ln_trade_imf, name(limf, replace)
graph combine lun lbaci limf
graph export figure\hist_lntrade.png, replace

hist ln_fdi
graph export figure\hist_lnfdi.png, replace


//Correlation matrix (Takes a long time)
/*
graph matrix col col1 csl cnl lp1 lpc, half
graph export figure\corr_indep.png, replace

pwcorr col col1 csl cnl lp1 lpc

//Summary statistics
outreg2 using table\summary_statistic, replace tex(frag) sum(log) label keep(tradeflow_comtrade_o tradeflow_baci tradeflow_imf_o fdi ln_trade_comtrade ln_trade_comtrade ln_trade_baci ln_trade_imf ln_fdi col csl cnl lp1 lpc ln_dist contig col_dep_ever comcol comrelig comleg_posttrans histwars) sortvar(tradeflow_comtrade_o tradeflow_baci tradeflow_imf_o fdi ln_trade_comtrade ln_trade_baci ln_trade_imf ln_fdi col col1 csl cnl lp1 lpc ln_dist contig col_dep_ever comcol comrelig comleg_posttrans histwars)
*/

//Baseline Result
//Trade (Comtrade)

forvalues j=1/9{

reghdfe ln_trade_comtrade ${vars`j'} $controls $conditions1, absorb(iso3num_o#year iso3num_d#year) cluster(iso3num_o#iso3num_d)

outreg2 using table\result_comtrade_ols1_c, tex(frag) append addtext(Exporter $\times$ Year FE, YES, Importer $\times$ Year FE, YES) nor2 adds(Adjusted R-squared, e(r2_a)) adec(3) label nonotes addnote("Standard errors are clustered at the origin-destination pair level.", "*** p<0.01, ** p<0.05, * p<0.1") ctitle(" ") sortvar(col csl cnl lp1 lpc $controls)

ppmlhdfe tradeflow_comtrade_o ${vars`j'} $controls $conditions1, absorb(iso3num_o#year iso3num_d#year) cluster(iso3num_o#iso3num_d)

outreg2 using table\result_comtrade_ppml1_c, tex(frag) append addtext(Exporter $\times$ Year FE, YES, Importer $\times$ Year FE, YES) nor2 adds(Pseudo R-squared, e(r2_p)) adec(3) label nonotes addnote("Standard errors are clustered at the origin-destination pair level.", "*** p<0.01, ** p<0.05, * p<0.1") ctitle(" ") sortvar(col csl cnl lp1 lpc $controls)

}

foreach  j in 1, 3, 4, 5, 6, 7, 8{

reghdfe ln_trade_comtrade ${vars`j'} $controls ${conditions2}, absorb(iso3num_o#year iso3num_d#year) cluster(iso3num_o#iso3num_d)

outreg2 using table\result_comtrade_ols2_c, tex(frag) append addtext(Exporter $\times$ Year FE, YES, Importer $\times$ Year FE, YES) nor2 adds(Adjusted R-squared, e(r2_a)) adec(3) label nonotes addnote("Standard errors are clustered at the origin-destination pair level.", "*** p<0.01, ** p<0.05, * p<0.1") ctitle(" ") sortvar(csl cnl lp1 lpc $controls)

ppmlhdfe tradeflow_comtrade_o ${vars`j'} $controls ${conditions2}, absorb(iso3num_o#year iso3num_d#year) cluster(iso3num_o#iso3num_d)

outreg2 using table\result_comtrade_ppml2_c, tex(frag) append addtext(Exporter $\times$ Year FE, YES, Importer $\times$ Year FE, YES) nor2 adds(Pseudo R-squared, e(r2_p)) adec(3) label nonotes addnote("Standard errors are clustered at the origin-destination pair level.", "*** p<0.01, ** p<0.05, * p<0.1") ctitle(" ") sortvar(csl cnl lp1 lpc $controls)

}

//Trade (BACI)

forvalues j=1/9{

reghdfe ln_trade_baci ${vars`j'} $controls $conditions1, absorb(iso3num_o#year iso3num_d#year) cluster(iso3num_o#iso3num_d)

outreg2 using table\result_baci_ols1_c, tex(frag) append addtext(Exporter $\times$ Year FE, YES, Importer $\times$ Year FE, YES) nor2 adds(Adjusted R-squared, e(r2_a)) adec(3) label nonotes addnote("Standard errors are clustered at the origin-destination pair level.", "*** p<0.01, ** p<0.05, * p<0.1") ctitle(" ") sortvar(col csl cnl lp1 lpc $controls)

ppmlhdfe tradeflow_baci ${vars`j'} $controls $conditions1, absorb(iso3num_o#year iso3num_d#year) cluster(iso3num_o#iso3num_d)

outreg2 using table\result_baci_ppml1_c, tex(frag) append addtext(Exporter $\times$ Year FE, YES, Importer $\times$ Year FE, YES) nor2 adds(Pseudo R-squared, e(r2_p)) adec(3) label nonotes addnote("Standard errors are clustered at the origin-destination pair level.", "*** p<0.01, ** p<0.05, * p<0.1") ctitle(" ") sortvar(col csl cnl lp1 lpc $controls)

}

foreach  j in 1, 3, 4, 5, 6, 7, 8{

reghdfe ln_trade_baci ${vars`j'} $controls ${conditions2}, absorb(iso3num_o#year iso3num_d#year) cluster(iso3num_o#iso3num_d)

outreg2 using table\result_baci_ols2_c, tex(frag) append addtext(Exporter $\times$ Year FE, YES, Importer $\times$ Year FE, YES) nor2 adds(Adjusted R-squared, e(r2_a)) adec(3) label nonotes addnote("Standard errors are clustered at the origin-destination pair level.", "*** p<0.01, ** p<0.05, * p<0.1") ctitle(" ") sortvar(csl cnl lp1 lpc $controls)

ppmlhdfe tradeflow_baci ${vars`j'} $controls ${conditions2}, absorb(iso3num_o#year iso3num_d#year) cluster(iso3num_o#iso3num_d)

outreg2 using table\result_baci_ppml2_c, tex(frag) append addtext(Exporter $\times$ Year FE, YES, Importer $\times$ Year FE, YES) nor2 adds(Pseudo R-squared, e(r2_p)) adec(3) label nonotes addnote("Standard errors are clustered at the origin-destination pair level.", "*** p<0.01, ** p<0.05, * p<0.1") ctitle(" ") sortvar(csl cnl lp1 lpc $controls)

}


//Trade (IMF)

forvalues j=1/9{

reghdfe ln_trade_imf ${vars`j'} $controls $conditions1, absorb(iso3num_o#year iso3num_d#year) cluster(iso3num_o#iso3num_d)

outreg2 using table\result_imf_ols1_c, tex(frag) append addtext(Exporter $\times$ Year FE, YES, Importer $\times$ Year FE, YES) nor2 adds(Adjusted R-squared, e(r2_a)) adec(3) label nonotes addnote("Standard errors are clustered at the origin-destination pair level.", "*** p<0.01, ** p<0.05, * p<0.1") ctitle(" ") sortvar(col csl cnl lp1 lpc $controls)

ppmlhdfe tradeflow_imf_o ${vars`j'} $controls $conditions1, absorb(iso3num_o#year iso3num_d#year) cluster(iso3num_o#iso3num_d)

outreg2 using table\result_imf_ppml1_c, tex(frag) append addtext(Exporter $\times$ Year FE, YES, Importer $\times$ Year FE, YES) nor2 adds(Pseudo R-squared, e(r2_p)) adec(3) label nonotes addnote("Standard errors are clustered at the origin-destination pair level.", "*** p<0.01, ** p<0.05, * p<0.1") ctitle(" ") sortvar(col csl cnl lp1 lpc $controls)

}

**# Bookmark #3

foreach  j in 1, 3, 4, 5, 6, 7, 8{

reghdfe ln_trade_imf ${vars`j'} $controls ${conditions2}, absorb(iso3num_o#year iso3num_d#year) cluster(iso3num_o#iso3num_d)

outreg2 using table\result_imf_ols2_c, tex(frag) append addtext(Exporter $\times$ Year FE, YES, Importer $\times$ Year FE, YES) nor2 adds(Adjusted R-squared, e(r2_a)) adec(3) label nonotes addnote("Standard errors are clustered at the origin-destination pair level.", "*** p<0.01, ** p<0.05, * p<0.1") ctitle(" ") sortvar(csl cnl lp1 lpc $controls)

ppmlhdfe tradeflow_imf_o ${vars`j'} $controls ${conditions2}, absorb(iso3num_o#year iso3num_d#year) cluster(iso3num_o#iso3num_d)

outreg2 using table\result_imf_ppml2_c, tex(frag) append addtext(Exporter $\times$ Year FE, YES, Importer $\times$ Year FE, YES) nor2 adds(Pseudo R-squared, e(r2_p)) adec(3) label nonotes addnote("Standard errors are clustered at the origin-destination pair level.", "*** p<0.01, ** p<0.05, * p<0.1") ctitle(" ") sortvar(csl cnl lp1 lpc $controls)

}


//4. FDI

forvalues j=1/9{

reghdfe ln_fdi ${vars`j'} $controls ${conditions1}, absorb(iso3num_o#year iso3num_d#year) cluster(iso3num_o#iso3num_d)

outreg2 using table\result_fdi_ols1_c, tex(frag) append addtext(Exporter $\times$ Year FE, YES, Importer $\times$ Year FE, YES) nor2 adds(Adjusted R-squared, e(r2_a)) adec(3) label nonotes addnote("Standard errors are clustered at the origin-destination pair level.", "*** p<0.01, ** p<0.05, * p<0.1") ctitle(" ") sortvar($vars9 $controls)

ppmlhdfe fdi ${vars`j'} $controls ${conditions1}, absorb(iso3num_o#year iso3num_d#year) cluster(iso3num_o#iso3num_d)

outreg2 using table\result_fdi_ppml1_c, tex(frag) append addtext(Exporter $\times$ Year FE, YES, Importer $\times$ Year FE, YES) nor2 adds(Pseudo R-squared, e(r2_p)) adec(3) label nonotes addnote("Standard errors are clustered at the origin-destination pair level.", "*** p<0.01, ** p<0.05, * p<0.1") ctitle(" ") sortvar($vars9 $controls)

}



foreach  j in 1, 3, 4, 5, 6, 7, 8{
	
reghdfe ln_fdi ${vars`j'} $controls $conditions2, absorb(iso3num_o#year iso3num_d#year) cluster(iso3num_o#iso3num_d)

outreg2 using table\result_fdi_ols2_c, tex(frag) append addtext(Exporter $\times$ Year FE, YES, Importer $\times$ Year FE, YES) nor2 adds(Adjusted R-squared, e(r2_a)) adec(3) label nonotes addnote("Standard errors are clustered at the origin-destination pair level.", "*** p<0.01, ** p<0.05, * p<0.1") ctitle(" ") sortvar($vars8 $controls)

ppmlhdfe fdi ${vars`j'} $controls $conditions2, absorb(iso3num_o#year iso3num_d#year) cluster(iso3num_o#iso3num_d)

outreg2 using table\result_fdi_ppml2_c, tex(frag) append addtext(Exporter $\times$ Year FE, YES, Importer $\times$ Year FE, YES) nor2 adds(Pseudo R-squared, e(r2_p)) adec(3) label nonotes addnote("Standard errors are clustered at the origin-destination pair level.", "*** p<0.01, ** p<0.05, * p<0.1") ctitle(" ") sortvar($vars8 $controls)

}


//Evolution of the Linguistic Cost Over Time

//Trade (Comtrade)

reghdfe ln_trade_comtrade col csl cnl lp1 c.lp1#i.decades lpc c.lpc#i.decades ln_dist c.ln_dist#i.decades contig col_dep_ever comcol comrelig comleg_posttrans histwars if year<=2019, absorb(iso3num_o#year iso3num_d#year) cluster(iso3num_o#iso3num_d)

outreg2 using table\result_comtrade_ols_decades, tex(frag) replace addtext(Exporter $\times$ Year FE, YES, Importer $\times$ Year FE, YES) nor2 adds(Adjusted R-squared, e(r2_a)) adec(3) label nonotes addnote("Standard errors are clustered at the origin-destination pair level.", "*** p<0.01, ** p<0.05, * p<0.1") ctitle("OLS ${title1}")

est sto comtrade_ols1_decades

coefplot (comtrade_ols1_decades, label(LP(Tree)) keep(*.decades#*.lp1) rename(^.*([1-2][0-9][0-9][0-9])\.decades\#c\.lp1$ = "\1s", regex) msymbol(O)) (comtrade_ols1_decades, label(LP(Phonetics)) keep(*.decades#*.lpc) rename(^.*([1-2][0-9][0-9][0-9])\.decades\#c\.lpc$ = "\1s", regex) msymbol(S)) (comtrade_ols1_decades, label(log Distance) keep(*.decades#*.ln_dist) rename(^.*([1-2][0-9][0-9][0-9])\.decades\#c\.ln_dist$ = "\1s", regex) msymbol(T)), vertical name(comtrade_ols1_decades, replace) yline(0) ylabel(0, add)

graph export figure\comtrade_ols1_decades.png, replace

reghdfe ln_trade_comtrade csl cnl lp1 c.lp1#i.decades lpc c.lpc#i.decades ln_dist c.ln_dist#i.decades contig col_dep_ever comcol comrelig comleg_posttrans histwars if(year<=2019)&(un_member_o==1)&(un_member_d==1)&(terrchange_o==0)&(terrchange_d==0)&(col1==0)&(fdi>0), absorb(iso3num_o#year iso3num_d#year) cluster(iso3num_o#iso3num_d)

outreg2 using table\result_comtrade_ols_decades, tex(frag) append addtext(Exporter $\times$ Year FE, YES, Importer $\times$ Year FE, YES) nor2 adds(Adjusted R-squared, e(r2_a)) adec(3) label ctitle("OLS ${title2}")

est sto comtrade_ols2_decades

coefplot (comtrade_ols2_decades, label(LP(Tree)) keep(*.decades#*.lp1) rename(^.*([1-2][0-9][0-9][0-9])\.decades\#c\.lp1$ = "\1s", regex) msymbol(O)) (comtrade_ols2_decades, label(LP(Phonetics)) keep(*.decades#*.lpc) rename(^.*([1-2][0-9][0-9][0-9])\.decades\#c\.lpc$ = "\1s", regex) msymbol(S)) (comtrade_ols2_decades, label(log Distance) keep(*.decades#*.ln_dist) rename(^.*([1-2][0-9][0-9][0-9])\.decades\#c\.ln_dist$ = "\1s", regex) msymbol(T)), vertical name(comtrade_ols2_decades, replace) yline(0) ylabel(0, add)

graph export figure\comtrade_ols2_decades.png, replace

ppmlhdfe tradeflow_comtrade col csl cnl lp1 c.lp1#i.decades lpc c.lpc#i.decades ln_dist c.ln_dist#i.decades contig col_dep_ever comcol comrelig comleg_posttrans histwars if year<=2019, absorb(iso3num_o#year iso3num_d#year) cluster(iso3num_o#iso3num_d)

outreg2 using table\result_comtrade_ppml_decades, tex(frag) append addtext(Exporter $\times$ Year FE, YES, Importer $\times$ Year FE, YES) nor2 adds(Pseudo R-squared, e(r2_p)) adec(3) label ctitle("PPML ${title1}")

est sto comtrade_ppml1_decades

coefplot (comtrade_ppml1_decades, label(LP(Tree)) keep(*.decades#*.lp1) rename(^.*([1-2][0-9][0-9][0-9])\.decades\#c\.lp1$ = "\1s", regex) msymbol(O)) (comtrade_ppml1_decades, label(LP(Phonetics)) keep(*.decades#*.lpc) rename(^.*([1-2][0-9][0-9][0-9])\.decades\#c\.lpc$ = "\1s", regex) msymbol(S)) (comtrade_ppml1_decades, label(log Distance) keep(*.decades#*.ln_dist) rename(^.*([1-2][0-9][0-9][0-9])\.decades\#c\.ln_dist$ = "\1s", regex) msymbol(T)), vertical name(comtrade_ppml1_decades, replace) yline(0) ylabel(0, add)

graph export figure\comtrade_ppml1_decades.png, replace

ppmlhdfe tradeflow_comtrade csl cnl lp1 c.lp1#i.decades lpc c.lpc#i.decades ln_dist c.ln_dist#i.decades contig col_dep_ever comcol comrelig comleg_posttrans histwars if(year<=2019)&(un_member_o==1)&(un_member_d==1)&(terrchange_o==0)&(terrchange_d==0)&(col1==0)&(fdi>0), absorb(iso3num_o#year iso3num_d#year) cluster(iso3num_o#iso3num_d)

outreg2 using table\result_comtrade_ppml_decades, tex(frag) append addtext(Exporter $\times$ Year FE, YES, Importer $\times$ Year FE, YES) nor2 adds(Pseudo R-squared, e(r2_p)) adec(3) label ctitle("PPML ${title2}") sortvar($vars8 $controls)
	
est sto comtrade_ppml2_decades

coefplot (comtrade_ppml2_decades, label(LP(Tree)) keep(*.decades#*.lp1) rename(^.*([1-2][0-9][0-9][0-9])\.decades\#c\.lp1$ = "\1s", regex) msymbol(O)) (comtrade_ppml2_decades, label(LP(Phonetics)) keep(*.decades#*.lpc) rename(^.*([1-2][0-9][0-9][0-9])\.decades\#c\.lpc$ = "\1s", regex) msymbol(S)) (comtrade_ppml2_decades, label(log Distance) keep(*.decades#*.ln_dist) rename(^.*([1-2][0-9][0-9][0-9])\.decades\#c\.ln_dist$ = "\1s", regex) msymbol(T)), vertical name(comtrade_ppml2_decades, replace) yline(0) ylabel(0, add)

graph export figure\comtrade_ppml2_decades.png, replace	

reghdfe ln_trade_comtrade col csl cnl lp1 c.lp1#i.year lpc c.lpc#i.year ln_dist c.ln_dist#i.year contig col_dep_ever comcol comrelig comleg_posttrans histwars if year>=2000, absorb(iso3num_o#year iso3num_d#year) cluster(iso3num_o#iso3num_d)

outreg2 using table\result_comtrade_ols_years, tex(frag) replace addtext(Exporter $\times$ Year FE, YES, Importer $\times$ Year FE, YES) nor2 adds(Adjusted R-squared, e(r2_a)) adec(3) label nonotes addnote("Standard errors are clustered at the origin-destination pair level.", "*** p<0.01, ** p<0.05, * p<0.1") ctitle("OLS ${title1}")

est sto comtrade_ols1_years

coefplot (comtrade_ols1_years, label(LP(Tree)) keep(*.year#*.lp1) rename(^.*([1-2][0-9][0-9][0-9])\.year\#c\.lp1$ = \1, regex)) (comtrade_ols1_years, label(LP(Phonetics)) keep(*.year#*.lpc) rename(^.*([1-2][0-9][0-9][0-9])\.year\#c\.lpc$ = \1, regex) msymbol(S)) (comtrade_ols1_years, label(log Distance) keep(*.year#*.ln_dist) rename(^.*([1-2][0-9][0-9][0-9])\.year\#c\.ln_dist$ = \1, regex) msymbol(T)), vertical name(comtrade_ols1_years, replace) yline(0) xlabel(, ang(45)) ylabel(0, add)

graph export figure\comtrade_ols1_years.png, replace

reghdfe ln_trade_comtrade csl cnl lp1 c.lp1#i.year lpc c.lpc#i.year ln_dist c.ln_dist#i.year contig col_dep_ever comcol comrelig comleg_posttrans histwars if(year>=2000)&(un_member_o==1)&(un_member_d==1)&(terrchange_o==0)&(terrchange_d==0)&(col1==0)&(fdi>0), absorb(iso3num_o#year iso3num_d#year) cluster(iso3num_o#iso3num_d)

outreg2 using table\result_comtrade_ols_years, tex(frag) append addtext(Exporter $\times$ Year FE, YES, Importer $\times$ Year FE, YES) nor2 adds(Adjusted R-squared, e(r2_a)) adec(3) label ctitle("OLS ${title2}")
	
est sto comtrade_ols2_years

coefplot (comtrade_ols2_years, label(LP(Tree)) keep(*.year#*.lp1) rename(^.*([1-2][0-9][0-9][0-9])\.year\#c\.lp1$ = \1, regex)) (comtrade_ols2_years, label(LP(Phonetics)) keep(*.year#*.lpc) rename(^.*([1-2][0-9][0-9][0-9])\.year\#c\.lpc$ = \1, regex) msymbol(S)) (comtrade_ols2_years, label(log Distance) keep(*.year#*.ln_dist) rename(^.*([1-2][0-9][0-9][0-9])\.year\#c\.ln_dist$ = \1, regex) msymbol(T)), vertical name(comtrade_ols2_years, replace) yline(0) xlabel(, ang(45)) ylabel(0, add)

graph export figure\comtrade_ols2_years.png, replace

ppmlhdfe tradeflow_comtrade_o col csl cnl lp1 c.lp1#i.year lpc c.lpc#i.year ln_dist c.ln_dist#i.year contig col_dep_ever comcol comrelig comleg_posttrans histwars if year>=2000, absorb(iso3num_o#year iso3num_d#year) cluster(iso3num_o#iso3num_d)

outreg2 using table\result_comtrade_ppml_years, tex(frag) append addtext(Exporter $\times$ Year FE, YES, Importer $\times$ Year FE, YES) nor2 adds(Pseudo R-squared, e(r2_p)) adec(3) label ctitle("PPML ${title1}")

est sto comtrade_ppml1_years

coefplot (comtrade_ppml1_years, label(LP(Tree)) keep(*.year#*.lp1) rename(^.*([1-2][0-9][0-9][0-9])\.year\#c\.lp1$ = \1, regex)) (comtrade_ppml1_years, label(LP(Phonetics)) keep(*.year#*.lpc) rename(^.*([1-2][0-9][0-9][0-9])\.year\#c\.lpc$ = \1, regex) msymbol(S)) (comtrade_ppml1_years, label(log Distance) keep(*.year#*.ln_dist) rename(^.*([1-2][0-9][0-9][0-9])\.year\#c\.ln_dist$ = \1, regex) msymbol(T)), vertical name(comtrade_ppml1_years, replace) yline(0) xlabel(, ang(45)) ylabel(0, add)

graph export figure\comtrade_ppml1_years.png, replace

ppmlhdfe tradeflow_comtrade_o csl cnl lp1 c.lp1#i.year lpc c.lpc#i.year ln_dist c.ln_dist#i.year contig col_dep_ever comcol comrelig comleg_posttrans histwars if(year>=2000)&(un_member_o==1)&(un_member_d==1)&(terrchange_o==0)&(terrchange_d==0)&(col1==0)&(fdi>0), absorb(iso3num_o#year iso3num_d#year) cluster(iso3num_o#iso3num_d)

outreg2 using table\result_comtrade_ppml_years, tex(frag) append addtext(Exporter $\times$ Year FE, YES, Importer $\times$ Year FE, YES) nor2 adds(Pseudo R-squared, e(r2_p)) adec(3) label ctitle("PPML ${title2}") sortvar($vars8 $controls)
	
est sto comtrade_ppml2_years

coefplot (comtrade_ppml2_years, label(LP(Tree)) keep(*.year#*.lp1) rename(^.*([1-2][0-9][0-9][0-9])\.year\#c\.lp1$ = \1, regex)) (comtrade_ppml2_years, label(LP(Phonetics)) keep(*.year#*.lpc) rename(^.*([1-2][0-9][0-9][0-9])\.year\#c\.lpc$ = \1, regex) msymbol(S)) (comtrade_ppml2_years, label(log Distance) keep(*.year#*.ln_dist) rename(^.*([1-2][0-9][0-9][0-9])\.year\#c\.ln_dist$ = \1, regex) msymbol(T)), vertical name(comtrade_ppml2_years, replace) yline(0) xlabel(, ang(45)) ylabel(0, add)

graph export figure\comtrade_ppml2_years.png, replace


//Trade (BACI)

reghdfe ln_trade_baci col csl cnl lp1 c.lp1#i.decades lpc c.lpc#i.decades ln_dist c.ln_dist#i.decades contig col_dep_ever comcol comrelig comleg_posttrans histwars if year<=2019, absorb(iso3num_o#year iso3num_d#year) cluster(iso3num_o#iso3num_d)

outreg2 using table\result_baci_ols_decades, tex(frag) replace addtext(Exporter $\times$ Year FE, YES, Importer $\times$ Year FE, YES) nor2 adds(Adjusted R-squared, e(r2_a)) adec(3) label nonotes addnote("Standard errors are clustered at the origin-destination pair level.", "*** p<0.01, ** p<0.05, * p<0.1") ctitle("OLS ${title1}")

est sto baci_ols1_decades

coefplot (baci_ols1_decades, label(LP(Tree)) keep(*.decades#*.lp1) rename(^.*([1-2][0-9][0-9][0-9])\.decades\#c\.lp1$ = "\1s", regex) msymbol(O)) (baci_ols1_decades, label(LP(Phonetics)) keep(*.decades#*.lpc) rename(^.*([1-2][0-9][0-9][0-9])\.decades\#c\.lpc$ = "\1s", regex) msymbol(S)) (baci_ols1_decades, label(log Distance) keep(*.decades#*.ln_dist) rename(^.*([1-2][0-9][0-9][0-9])\.decades\#c\.ln_dist$ = "\1s", regex) msymbol(T)), vertical name(baci_ols1_decades, replace) yline(0) ylabel(0, add)

graph export figure\baci_ols1_decades.png, replace

reghdfe ln_trade_baci csl cnl lp1 c.lp1#i.decades lpc c.lpc#i.decades ln_dist c.ln_dist#i.decades contig col_dep_ever comcol comrelig comleg_posttrans histwars if(year<=2019)&(un_member_o==1)&(un_member_d==1)&(terrchange_o==0)&(terrchange_d==0)&(col1==0)&(fdi>0), absorb(iso3num_o#year iso3num_d#year) cluster(iso3num_o#iso3num_d)

outreg2 using table\result_baci_ols_decades, tex(frag) append addtext(Exporter $\times$ Year FE, YES, Importer $\times$ Year FE, YES) nor2 adds(Adjusted R-squared, e(r2_a)) adec(3) label ctitle("OLS ${title2}")

est sto baci_ols2_decades

coefplot (baci_ols2_decades, label(LP(Tree)) keep(*.decades#*.lp1) rename(^.*([1-2][0-9][0-9][0-9])\.decades\#c\.lp1$ = "\1s", regex) msymbol(O)) (baci_ols2_decades, label(LP(Phonetics)) keep(*.decades#*.lpc) rename(^.*([1-2][0-9][0-9][0-9])\.decades\#c\.lpc$ = "\1s", regex) msymbol(S)) (baci_ols2_decades, label(log Distance) keep(*.decades#*.ln_dist) rename(^.*([1-2][0-9][0-9][0-9])\.decades\#c\.ln_dist$ = "\1s", regex) msymbol(T)), vertical name(baci_ols2_decades, replace) yline(0) ylabel(0, add)

graph export figure\baci_ols2_decades.png, replace

ppmlhdfe tradeflow_baci col csl cnl lp1 c.lp1#i.decades lpc c.lpc#i.decades ln_dist c.ln_dist#i.decades contig col_dep_ever comcol comrelig comleg_posttrans histwars if year<=2019, absorb(iso3num_o#year iso3num_d#year) cluster(iso3num_o#iso3num_d)

outreg2 using table\result_baci_ppml_decades, tex(frag) append addtext(Exporter $\times$ Year FE, YES, Importer $\times$ Year FE, YES) nor2 adds(Pseudo R-squared, e(r2_p)) adec(3) label ctitle("PPML ${title1}")

est sto baci_ppml1_decades

coefplot (baci_ppml1_decades, label(LP(Tree)) keep(*.decades#*.lp1) rename(^.*([1-2][0-9][0-9][0-9])\.decades\#c\.lp1$ = "\1s", regex) msymbol(O)) (baci_ppml1_decades, label(LP(Phonetics)) keep(*.decades#*.lpc) rename(^.*([1-2][0-9][0-9][0-9])\.decades\#c\.lpc$ = "\1s", regex) msymbol(S)) (baci_ppml1_decades, label(log Distance) keep(*.decades#*.ln_dist) rename(^.*([1-2][0-9][0-9][0-9])\.decades\#c\.ln_dist$ = "\1s", regex) msymbol(T)), vertical name(baci_ppml1_decades, replace) yline(0) ylabel(0, add)

graph export figure\baci_ppml1_decades.png, replace

ppmlhdfe tradeflow_baci csl cnl lp1 c.lp1#i.decades lpc c.lpc#i.decades ln_dist c.ln_dist#i.decades contig col_dep_ever comcol comrelig comleg_posttrans histwars if(year<=2019)&(un_member_o==1)&(un_member_d==1)&(terrchange_o==0)&(terrchange_d==0)&(col1==0)&(fdi>0), absorb(iso3num_o#year iso3num_d#year) cluster(iso3num_o#iso3num_d)

outreg2 using table\result_baci_ppml_decades, tex(frag) append addtext(Exporter $\times$ Year FE, YES, Importer $\times$ Year FE, YES) nor2 adds(Pseudo R-squared, e(r2_p)) adec(3) label ctitle("PPML ${title2}") sortvar($vars8 $controls)
	
est sto baci_ppml2_decades

coefplot (baci_ppml2_decades, label(LP(Tree)) keep(*.decades#*.lp1) rename(^.*([1-2][0-9][0-9][0-9])\.decades\#c\.lp1$ = "\1s", regex) msymbol(O)) (baci_ppml2_decades, label(LP(Phonetics)) keep(*.decades#*.lpc) rename(^.*([1-2][0-9][0-9][0-9])\.decades\#c\.lpc$ = "\1s", regex) msymbol(S)) (baci_ppml2_decades, label(log Distance) keep(*.decades#*.ln_dist) rename(^.*([1-2][0-9][0-9][0-9])\.decades\#c\.ln_dist$ = "\1s", regex) msymbol(T)), vertical name(baci_ppml2_decades, replace) yline(0) ylabel(0, add)

graph export figure\baci_ppml2_decades.png, replace	

reghdfe ln_trade_baci col csl cnl lp1 c.lp1#i.year lpc c.lpc#i.year ln_dist c.ln_dist#i.year contig col_dep_ever comcol comrelig comleg_posttrans histwars if year>=2000, absorb(iso3num_o#year iso3num_d#year) cluster(iso3num_o#iso3num_d)

outreg2 using table\result_baci_ols_years, tex(frag) replace addtext(Exporter $\times$ Year FE, YES, Importer $\times$ Year FE, YES) nor2 adds(Adjusted R-squared, e(r2_a)) adec(3) label nonotes addnote("Standard errors are clustered at the origin-destination pair level.", "*** p<0.01, ** p<0.05, * p<0.1") ctitle("OLS ${title1}")

est sto baci_ols1_years

coefplot (baci_ols1_years, label(LP(Tree)) keep(*.year#*.lp1) rename(^.*([1-2][0-9][0-9][0-9])\.year\#c\.lp1$ = \1, regex) msymbol(O)) (baci_ols1_years, label(LP(Phonetics)) keep(*.year#*.lpc) rename(^.*([1-2][0-9][0-9][0-9])\.year\#c\.lpc$ = \1, regex) msymbol(S)) (baci_ols1_years, label(log Distance) keep(*.year#*.ln_dist) rename(^.*([1-2][0-9][0-9][0-9])\.year\#c\.ln_dist$ = \1, regex) msymbol(T)), vertical name(baci_ols1_years, replace) yline(0) xlabel(, ang(45)) ylabel(0, add)

graph export figure\baci_ols1_years.png, replace

reghdfe ln_trade_baci csl cnl lp1 c.lp1#i.year lpc c.lpc#i.year ln_dist c.ln_dist#i.year contig col_dep_ever comcol comrelig comleg_posttrans histwars if(year>=2000)&(un_member_o==1)&(un_member_d==1)&(terrchange_o==0)&(terrchange_d==0)&(col1==0)&(fdi>0), absorb(iso3num_o#year iso3num_d#year) cluster(iso3num_o#iso3num_d)

outreg2 using table\result_baci_ols_years, tex(frag) append addtext(Exporter $\times$ Year FE, YES, Importer $\times$ Year FE, YES) nor2 adds(Adjusted R-squared, e(r2_a)) adec(3) label ctitle("OLS ${title2}")
	
est sto baci_ols2_years

coefplot (baci_ols2_years, label(LP(Tree)) keep(*.year#*.lp1) rename(^.*([1-2][0-9][0-9][0-9])\.year\#c\.lp1$ = \1, regex)) (baci_ols2_years, label(LP(Phonetics)) keep(*.year#*.lpc) rename(^.*([1-2][0-9][0-9][0-9])\.year\#c\.lpc$ = \1, regex) msymbol(S)) (baci_ols2_years, label(log Distance) keep(*.year#*.ln_dist) rename(^.*([1-2][0-9][0-9][0-9])\.year\#c\.ln_dist$ = \1, regex) msymbol(T)), vertical name(baci_ols2_years, replace) yline(0) xlabel(, ang(45)) ylabel(0, add)

graph export figure\baci_ols2_years.png, replace

ppmlhdfe tradeflow_baci col csl cnl lp1 c.lp1#i.year lpc c.lpc#i.year ln_dist c.ln_dist#i.year contig col_dep_ever comcol comrelig comleg_posttrans histwars if year>=2000, absorb(iso3num_o#year iso3num_d#year) cluster(iso3num_o#iso3num_d)

outreg2 using table\result_baci_ppml_years, tex(frag) append addtext(Exporter $\times$ Year FE, YES, Importer $\times$ Year FE, YES) nor2 adds(Pseudo R-squared, e(r2_p)) adec(3) label ctitle("PPML ${title1}")

est sto baci_ppml1_years

coefplot (baci_ppml1_years, label(LP(Tree)) keep(*.year#*.lp1) rename(^.*([1-2][0-9][0-9][0-9])\.year\#c\.lp1$ = \1, regex)) (baci_ppml1_years, label(LP(Phonetics)) keep(*.year#*.lpc) rename(^.*([1-2][0-9][0-9][0-9])\.year\#c\.lpc$ = \1, regex) msymbol(S)) (baci_ppml1_years, label(log Distance) keep(*.year#*.ln_dist) rename(^.*([1-2][0-9][0-9][0-9])\.year\#c\.ln_dist$ = \1, regex) msymbol(T)), vertical name(baci_ppml1_years, replace) yline(0) xlabel(, ang(45)) ylabel(0, add)

graph export figure\baci_ppml1_years.png, replace

ppmlhdfe tradeflow_baci csl cnl lp1 c.lp1#i.year lpc c.lpc#i.year ln_dist c.ln_dist#i.year contig col_dep_ever comcol comrelig comleg_posttrans histwars if(year>=2000)&(un_member_o==1)&(un_member_d==1)&(terrchange_o==0)&(terrchange_d==0)&(col1==0)&(fdi>0), absorb(iso3num_o#year iso3num_d#year) cluster(iso3num_o#iso3num_d)

outreg2 using table\result_baci_ppml_years, tex(frag) append addtext(Exporter $\times$ Year FE, YES, Importer $\times$ Year FE, YES) nor2 adds(Pseudo R-squared, e(r2_p)) adec(3) label ctitle("PPML ${title2}") sortvar(col $vars8 $controls)
	
est sto baci_ppml2_years

coefplot (baci_ppml2_years, label(LP(Tree)) keep(*.year#*.lp1) rename(^.*([1-2][0-9][0-9][0-9])\.year\#c\.lp1$ = \1, regex)) (baci_ppml2_years, label(LP(Phonetics)) keep(*.year#*.lpc) rename(^.*([1-2][0-9][0-9][0-9])\.year\#c\.lpc$ = \1, regex) msymbol(S)) (baci_ppml2_years, label(log Distance) keep(*.year#*.ln_dist) rename(^.*([1-2][0-9][0-9][0-9])\.year\#c\.ln_dist$ = \1, regex) msymbol(T)), vertical name(baci_ppml2_years, replace) yline(0) xlabel(, ang(45)) ylabel(0, add)

graph export figure\baci_ppml2_years.png, replace


//Trade (IMF)

reghdfe ln_trade_imf col csl cnl lp1 c.lp1#i.decades lpc c.lpc#i.decades ln_dist c.ln_dist#i.decades contig col_dep_ever comcol comrelig comleg_posttrans histwars if year<=2019, absorb(iso3num_o#year iso3num_d#year) cluster(iso3num_o#iso3num_d)

outreg2 using table\result_imf_ols_decades, tex(frag) replace addtext(Exporter $\times$ Year FE, YES, Importer $\times$ Year FE, YES) nor2 adds(Adjusted R-squared, e(r2_a)) adec(3) label nonotes addnote("Standard errors are clustered at the origin-destination pair level.", "*** p<0.01, ** p<0.05, * p<0.1") ctitle("OLS ${title1}")

est sto imf_ols1_decades

coefplot (imf_ols1_decades, label(LP(Tree)) keep(*.decades#*.lp1) rename(^.*([1-2][0-9][0-9][0-9])\.decades\#c\.lp1$ = "\1s", regex) msymbol(O)) (imf_ols1_decades, label(LP(Phonetics)) keep(*.decades#*.lpc) rename(^.*([1-2][0-9][0-9][0-9])\.decades\#c\.lpc$ = "\1s", regex) msymbol(S)) (imf_ols1_decades, label(log Distance) keep(*.decades#*.ln_dist) rename(^.*([1-2][0-9][0-9][0-9])\.decades\#c\.ln_dist$ = "\1s", regex) msymbol(T)), vertical name(imf_ols1_decades, replace) yline(0) ylabel(0, add)

graph export figure\imf_ols1_decades.png, replace

reghdfe ln_trade_imf csl cnl lp1 c.lp1#i.decades lpc c.lpc#i.decades ln_dist c.ln_dist#i.decades contig col_dep_ever comcol comrelig comleg_posttrans histwars if(year<=2019)&(un_member_o==1)&(un_member_d==1)&(terrchange_o==0)&(terrchange_d==0)&(col1==0)&(fdi>0), absorb(iso3num_o#year iso3num_d#year) cluster(iso3num_o#iso3num_d)

outreg2 using table\result_imf_ols_decades, tex(frag) append addtext(Exporter $\times$ Year FE, YES, Importer $\times$ Year FE, YES) nor2 adds(Adjusted R-squared, e(r2_a)) adec(3) label ctitle("OLS ${title2}")

est sto imf_ols2_decades

coefplot (imf_ols2_decades, label(LP(Tree)) keep(*.decades#*.lp1) rename(^.*([1-2][0-9][0-9][0-9])\.decades\#c\.lp1$ = "\1s", regex) msymbol(O)) (imf_ols2_decades, label(LP(Phonetics)) keep(*.decades#*.lpc) rename(^.*([1-2][0-9][0-9][0-9])\.decades\#c\.lpc$ = "\1s", regex) msymbol(S)) (imf_ols2_decades, label(log Distance) keep(*.decades#*.ln_dist) rename(^.*([1-2][0-9][0-9][0-9])\.decades\#c\.ln_dist$ = "\1s", regex) msymbol(T)), vertical name(imf_ols2_decades, replace) yline(0) ylabel(0, add)

graph export figure\imf_ols2_decades.png, replace

ppmlhdfe tradeflow_imf col csl cnl lp1 c.lp1#i.decades lpc c.lpc#i.decades ln_dist c.ln_dist#i.decades contig col_dep_ever comcol comrelig comleg_posttrans histwars if year<=2019, absorb(iso3num_o#year iso3num_d#year) cluster(iso3num_o#iso3num_d)

outreg2 using table\result_imf_ppml_decades, tex(frag) append addtext(Exporter $\times$ Year FE, YES, Importer $\times$ Year FE, YES) nor2 adds(Pseudo R-squared, e(r2_p)) adec(3) label ctitle("PPML ${title1}")

est sto imf_ppml1_decades

coefplot (imf_ppml1_decades, label(LP(Tree)) keep(*.decades#*.lp1) rename(^.*([1-2][0-9][0-9][0-9])\.decades\#c\.lp1$ = "\1s", regex) msymbol(O)) (imf_ppml1_decades, label(LP(Phonetics)) keep(*.decades#*.lpc) rename(^.*([1-2][0-9][0-9][0-9])\.decades\#c\.lpc$ = "\1s", regex) msymbol(S)) (imf_ppml1_decades, label(log Distance) keep(*.decades#*.ln_dist) rename(^.*([1-2][0-9][0-9][0-9])\.decades\#c\.ln_dist$ = "\1s", regex) msymbol(T)), vertical name(imf_ppml1_decades, replace) yline(0) ylabel(0, add)

graph export figure\imf_ppml1_decades.png, replace

ppmlhdfe tradeflow_imf csl cnl lp1 c.lp1#i.decades lpc c.lpc#i.decades ln_dist c.ln_dist#i.decades contig col_dep_ever comcol comrelig comleg_posttrans histwars if(year<=2019)&(un_member_o==1)&(un_member_d==1)&(terrchange_o==0)&(terrchange_d==0)&(col1==0)&(fdi>0), absorb(iso3num_o#year iso3num_d#year) cluster(iso3num_o#iso3num_d)

outreg2 using table\result_imf_ppml_decades, tex(frag) append addtext(Exporter $\times$ Year FE, YES, Importer $\times$ Year FE, YES) nor2 adds(Pseudo R-squared, e(r2_p)) adec(3) label ctitle("PPML ${title2}") sortvar($vars8 $controls)
	
est sto imf_ppml2_decades

coefplot (imf_ppml2_decades, label(LP(Tree)) keep(*.decades#*.lp1) rename(^.*([1-2][0-9][0-9][0-9])\.decades\#c\.lp1$ = "\1s", regex) msymbol(O)) (imf_ppml2_decades, label(LP(Phonetics)) keep(*.decades#*.lpc) rename(^.*([1-2][0-9][0-9][0-9])\.decades\#c\.lpc$ = "\1s", regex) msymbol(S)) (imf_ppml2_decades, label(log Distance) keep(*.decades#*.ln_dist) rename(^.*([1-2][0-9][0-9][0-9])\.decades\#c\.ln_dist$ = "\1s", regex) msymbol(T)), vertical name(imf_ppml2_decades, replace) yline(0) ylabel(0, add)

graph export figure\imf_ppml2_decades.png, replace	

reghdfe ln_trade_imf col csl cnl lp1 c.lp1#i.year lpc c.lpc#i.year ln_dist c.ln_dist#i.year contig col_dep_ever comcol comrelig comleg_posttrans histwars if year>=2000, absorb(iso3num_o#year iso3num_d#year) cluster(iso3num_o#iso3num_d)

outreg2 using table\result_imf_ols_years, tex(frag) replace addtext(Exporter $\times$ Year FE, YES, Importer $\times$ Year FE, YES) nor2 adds(Adjusted R-squared, e(r2_a)) adec(3) label nonotes addnote("Standard errors are clustered at the origin-destination pair level.", "*** p<0.01, ** p<0.05, * p<0.1") ctitle("OLS ${title1}")

est sto imf_ols1_years

coefplot (imf_ols1_years, label(LP(Tree)) keep(*.year#*.lp1) rename(^.*([1-2][0-9][0-9][0-9])\.year\#c\.lp1$ = \1, regex)) (imf_ols1_years, label(LP(Phonetics)) keep(*.year#*.lpc) rename(^.*([1-2][0-9][0-9][0-9])\.year\#c\.lpc$ = \1, regex) msymbol(S)) (imf_ols1_years, label(log Distance) keep(*.year#*.ln_dist) rename(^.*([1-2][0-9][0-9][0-9])\.year\#c\.ln_dist$ = \1, regex) msymbol(T)), vertical name(imf_ols1_years, replace) yline(0) xlabel(, ang(45)) ylabel(0, add)

graph export figure\imf_ols1_years.png, replace

reghdfe ln_trade_imf csl cnl lp1 c.lp1#i.year lpc c.lpc#i.year ln_dist c.ln_dist#i.year contig col_dep_ever comcol comrelig comleg_posttrans histwars if(year>=2000)&(un_member_o==1)&(un_member_d==1)&(terrchange_o==0)&(terrchange_d==0)&(col1==0)&(fdi>0), absorb(iso3num_o#year iso3num_d#year) cluster(iso3num_o#iso3num_d)

outreg2 using table\result_imf_ols_years, tex(frag) append addtext(Exporter $\times$ Year FE, YES, Importer $\times$ Year FE, YES) nor2 adds(Adjusted R-squared, e(r2_a)) adec(3) label ctitle("OLS ${title2}")
	
est sto imf_ols2_years

coefplot (imf_ols2_years, label(LP(Tree)) keep(*.year#*.lp1) rename(^.*([1-2][0-9][0-9][0-9])\.year\#c\.lp1$ = \1, regex)) (imf_ols2_years, label(LP(Phonetics)) keep(*.year#*.lpc) rename(^.*([1-2][0-9][0-9][0-9])\.year\#c\.lpc$ = \1, regex) msymbol(S)) (imf_ols2_years, label(log Distance) keep(*.year#*.ln_dist) rename(^.*([1-2][0-9][0-9][0-9])\.year\#c\.ln_dist$ = \1, regex) msymbol(T)), vertical name(imf_ols2_years, replace) yline(0) xlabel(, ang(45)) ylabel(0, add)

graph export figure\imf_ols2_years.png, replace

ppmlhdfe tradeflow_imf_o col csl cnl lp1 c.lp1#i.year lpc c.lpc#i.year ln_dist c.ln_dist#i.year contig col_dep_ever comcol comrelig comleg_posttrans histwars if year>=2000, absorb(iso3num_o#year iso3num_d#year) cluster(iso3num_o#iso3num_d)

outreg2 using table\result_imf_ppml_years, tex(frag) append addtext(Exporter $\times$ Year FE, YES, Importer $\times$ Year FE, YES) nor2 adds(Pseudo R-squared, e(r2_p)) adec(3) label ctitle("PPML ${title1}")

est sto imf_ppml1_years

coefplot (imf_ppml1_years, label(LP(Tree)) keep(*.year#*.lp1) rename(^.*([1-2][0-9][0-9][0-9])\.year\#c\.lp1$ = \1, regex)) (imf_ppml1_years, label(LP(Phonetics)) keep(*.year#*.lpc) rename(^.*([1-2][0-9][0-9][0-9])\.year\#c\.lpc$ = \1, regex) msymbol(S)) (imf_ppml1_years, label(log Distance) keep(*.year#*.ln_dist) rename(^.*([1-2][0-9][0-9][0-9])\.year\#c\.ln_dist$ = \1, regex) msymbol(T)), vertical name(imf_ppml1_years, replace) yline(0) xlabel(, ang(45)) ylabel(0, add)

graph export figure\imf_ppml1_years.png, replace

ppmlhdfe tradeflow_imf_o csl cnl lp1 c.lp1#i.year lpc c.lpc#i.year ln_dist c.ln_dist#i.year contig col_dep_ever comcol comrelig comleg_posttrans histwars if(year>=2000)&(un_member_o==1)&(un_member_d==1)&(terrchange_o==0)&(terrchange_d==0)&(col1==0)&(fdi>0), absorb(iso3num_o#year iso3num_d#year) cluster(iso3num_o#iso3num_d)

outreg2 using table\result_imf_ppml_years, tex(frag) append addtext(Exporter $\times$ Year FE, YES, Importer $\times$ Year FE, YES) nor2 adds(Pseudo R-squared, e(r2_p)) adec(3) label ctitle("PPML ${title2}") sortvar(col $vars8 $controls)
	
est sto imf_ppml2_years

coefplot (imf_ppml2_years, label(LP(Tree)) keep(*.year#*.lp1) rename(^.*([1-2][0-9][0-9][0-9])\.year\#c\.lp1$ = \1, regex)) (imf_ppml2_years, label(LP(Phonetics)) keep(*.year#*.lpc) rename(^.*([1-2][0-9][0-9][0-9])\.year\#c\.lpc$ = \1, regex) msymbol(S)) (imf_ppml2_years, label(log Distance) keep(*.year#*.ln_dist) rename(^.*([1-2][0-9][0-9][0-9])\.year\#c\.ln_dist$ = \1, regex) msymbol(T)), vertical name(imf_ppml2_years, replace) yline(0) xlabel(, ang(45)) ylabel(0, add)

graph export figure\imf_ppml2_years.png, replace


//FDI

reghdfe ln_fdi col csl cnl lp1 c.lp1#i.decades lpc c.lpc#i.decades ln_dist c.ln_dist#i.decades contig col_dep_ever comcol comrelig comleg_posttrans histwars if year<=2019, absorb(iso3num_o#year iso3num_d#year) cluster(iso3num_o#iso3num_d)

outreg2 using table\result_fdi_ols_decades, tex(frag) replace addtext(Exporter $\times$ Year FE, YES, Importer $\times$ Year FE, YES) nor2 adds(Adjusted R-squared, e(r2_a)) adec(3) label nonotes addnote("Standard errors are clustered at the origin-destination pair level.", "*** p<0.01, ** p<0.05, * p<0.1") ctitle("OLS ${title1}")

est sto fdi_ols1_decades

coefplot (fdi_ols1_decades, label(LP(Tree)) keep(*.decades#*.lp1) rename(^.*([1-2][0-9][0-9][0-9])\.decades\#c\.lp1$ = "\1s", regex) msymbol(O)) (fdi_ols1_decades, label(LP(Phonetics)) keep(*.decades#*.lpc) rename(^.*([1-2][0-9][0-9][0-9])\.decades\#c\.lpc$ = "\1s", regex) msymbol(S)) (fdi_ols1_decades, label(log Distance) keep(*.decades#*.ln_dist) rename(^.*([1-2][0-9][0-9][0-9])\.decades\#c\.ln_dist$ = "\1s", regex) msymbol(T)), vertical name(fdi_ols1_decades, replace) yline(0) ylabel(0, add)

graph export figure\fdi_ols1_decades.png, replace

reghdfe ln_fdi csl cnl lp1 c.lp1#i.decades lpc c.lpc#i.decades ln_dist c.ln_dist#i.decades contig col_dep_ever comcol comrelig comleg_posttrans histwars if(year<=2019)&(un_member_o==1)&(un_member_d==1)&(terrchange_o==0)&(terrchange_d==0)&(col1==0)&(fdi>0), absorb(iso3num_o#year iso3num_d#year) cluster(iso3num_o#iso3num_d)

outreg2 using table\result_fdi_ols_decades, tex(frag) append addtext(Exporter $\times$ Year FE, YES, Importer $\times$ Year FE, YES) nor2 adds(Adjusted R-squared, e(r2_a)) adec(3) label ctitle("OLS ${title2}")

est sto fdi_ols2_decades

coefplot (fdi_ols2_decades, label(LP(Tree)) keep(*.decades#*.lp1) rename(^.*([1-2][0-9][0-9][0-9])\.decades\#c\.lp1$ = "\1s", regex) msymbol(O)) (fdi_ols2_decades, label(LP(Phonetics)) keep(*.decades#*.lpc) rename(^.*([1-2][0-9][0-9][0-9])\.decades\#c\.lpc$ = "\1s", regex) msymbol(S)) (fdi_ols2_decades, label(log Distance) keep(*.decades#*.ln_dist) rename(^.*([1-2][0-9][0-9][0-9])\.decades\#c\.ln_dist$ = "\1s", regex) msymbol(T)), vertical name(fdi_ols2_decades, replace) yline(0) ylabel(0, add)

graph export figure\fdi_ols2_decades.png, replace

ppmlhdfe fdi col csl cnl lp1 c.lp1#i.decades lpc c.lpc#i.decades ln_dist c.ln_dist#i.decades contig col_dep_ever comcol comrelig comleg_posttrans histwars if year<=2019, absorb(iso3num_o#year iso3num_d#year) cluster(iso3num_o#iso3num_d)

outreg2 using table\result_fdi_ppml_decades, tex(frag) append addtext(Exporter $\times$ Year FE, YES, Importer $\times$ Year FE, YES) nor2 adds(Pseudo R-squared, e(r2_p)) adec(3) label ctitle("PPML ${title1}")

est sto fdi_ppml1_decades

coefplot (fdi_ppml1_decades, label(LP(Tree)) keep(*.decades#*.lp1) rename(^.*([1-2][0-9][0-9][0-9])\.decades\#c\.lp1$ = "\1s", regex) msymbol(O)) (fdi_ppml1_decades, label(LP(Phonetics)) keep(*.decades#*.lpc) rename(^.*([1-2][0-9][0-9][0-9])\.decades\#c\.lpc$ = "\1s", regex) msymbol(S)) (fdi_ppml1_decades, label(log Distance) keep(*.decades#*.ln_dist) rename(^.*([1-2][0-9][0-9][0-9])\.decades\#c\.ln_dist$ = "\1s", regex) msymbol(T)), vertical name(fdi_ppml1_decades, replace) yline(0) ylabel(0, add)

graph export figure\fdi_ppml1_decades.png, replace

ppmlhdfe fdi csl cnl lp1 c.lp1#i.decades lpc c.lpc#i.decades ln_dist c.ln_dist#i.decades contig col_dep_ever comcol comrelig comleg_posttrans histwars if(year<=2019)&(un_member_o==1)&(un_member_d==1)&(terrchange_o==0)&(terrchange_d==0)&(col1==0)&(fdi>0), absorb(iso3num_o#year iso3num_d#year) cluster(iso3num_o#iso3num_d)

outreg2 using table\result_fdi_ppml_decades, tex(frag) append addtext(Exporter $\times$ Year FE, YES, Importer $\times$ Year FE, YES) nor2 adds(Pseudo R-squared, e(r2_p)) adec(3) label ctitle("PPML ${title2}") sortvar($vars8 $controls)

est sto fdi_ppml2_decades

coefplot (fdi_ppml2_decades, label(LP(Tree)) keep(*.decades#*.lp1) rename(^.*([1-2][0-9][0-9][0-9])\.decades\#c\.lp1$ = "\1s", regex) msymbol(O)) (fdi_ppml2_decades, label(LP(Phonetics)) keep(*.decades#*.lpc) rename(^.*([1-2][0-9][0-9][0-9])\.decades\#c\.lpc$ = "\1s", regex) msymbol(S)) (fdi_ppml2_decades, label(log Distance) keep(*.decades#*.ln_dist) rename(^.*([1-2][0-9][0-9][0-9])\.decades\#c\.ln_dist$ = "\1s", regex) msymbol(T)), vertical name(fdi_ppml2_decades, replace) yline(0) ylabel(0, add)

graph export figure\fdi_ppml2_decades.png, replace

reghdfe ln_fdi col csl cnl lp1 c.lp1#i.year lpc c.lpc#i.year ln_dist c.ln_dist#i.year contig col_dep_ever comcol comrelig comleg_posttrans histwars if year>=2000, absorb(iso3num_o#year iso3num_d#year) cluster(iso3num_o#iso3num_d)

outreg2 using table\result_fdi_ols_years, tex(frag) replace addtext(Exporter $\times$ Year FE, YES, Importer $\times$ Year FE, YES) nor2 adds(Adjusted R-squared, e(r2_a)) adec(3) label nonotes addnote("Standard errors are clustered at the origin-destination pair level.", "*** p<0.01, ** p<0.05, * p<0.1") ctitle("OLS ${title1}")

est sto fdi_ols1_years

coefplot (fdi_ols1_years, label(LP(Tree)) keep(*.year#*.lp1) rename(^.*([1-2][0-9][0-9][0-9])\.year\#c\.lp1$ = \1, regex)) (fdi_ols1_years, label(LP(Phonetics)) keep(*.year#*.lpc) rename(^.*([1-2][0-9][0-9][0-9])\.year\#c\.lpc$ = \1, regex) msymbol(S)) (fdi_ols1_years, label(log Distance) keep(*.year#*.ln_dist) rename(^.*([1-2][0-9][0-9][0-9])\.year\#c\.ln_dist$ = \1, regex) msymbol(T)), vertical name(fdi_ols1_years, replace) yline(0) xlabel(, ang(45)) ylabel(0, add)

graph export figure\fdi_ols1_years.png, replace

reghdfe ln_fdi csl cnl lp1 c.lp1#i.year lpc c.lpc#i.year ln_dist c.ln_dist#i.year contig col_dep_ever comcol comrelig comleg_posttrans histwars if(year>=2000)&(un_member_o==1)&(un_member_d==1)&(terrchange_o==0)&(terrchange_d==0)&(col1==0)&(fdi>0), absorb(iso3num_o#year iso3num_d#year) cluster(iso3num_o#iso3num_d)

outreg2 using table\result_fdi_ols_years, tex(frag) append addtext(Exporter $\times$ Year FE, YES, Importer $\times$ Year FE, YES) nor2 adds(Adjusted R-squared, e(r2_a)) adec(3) label ctitle("OLS ${title2}")
	
est sto fdi_ols2_years

coefplot (fdi_ols2_years, label(LP(Tree)) keep(*.year#*.lp1) rename(^.*([1-2][0-9][0-9][0-9])\.year\#c\.lp1$ = \1, regex)) (fdi_ols2_years, label(LP(Phonetics)) keep(*.year#*.lpc) rename(^.*([1-2][0-9][0-9][0-9])\.year\#c\.lpc$ = \1, regex) msymbol(S)) (fdi_ols2_years, label(log Distance) keep(*.year#*.ln_dist) rename(^.*([1-2][0-9][0-9][0-9])\.year\#c\.ln_dist$ = \1, regex) msymbol(T)), vertical name(fdi_ols2_years, replace) yline(0) xlabel(, ang(45)) ylabel(0, add)

graph export figure\fdi_ols2_years.png, replace

ppmlhdfe fdi col csl cnl lp1 c.lp1#i.year lpc c.lpc#i.year ln_dist c.ln_dist#i.year contig col_dep_ever comcol comrelig comleg_posttrans histwars if year>=2000, absorb(iso3num_o#year iso3num_d#year) cluster(iso3num_o#iso3num_d)

outreg2 using table\result_fdi_ppml_years, tex(frag) append addtext(Exporter $\times$ Year FE, YES, Importer $\times$ Year FE, YES) nor2 adds(Pseudo R-squared, e(r2_p)) adec(3) label ctitle("PPML ${title1}")

est sto fdi_ppml1_years

coefplot (fdi_ppml1_years, label(LP(Tree)) keep(*.year#*.lp1) rename(^.*([1-2][0-9][0-9][0-9])\.year\#c\.lp1$ = \1, regex)) (fdi_ppml1_years, label(LP(Phonetics)) keep(*.year#*.lpc) rename(^.*([1-2][0-9][0-9][0-9])\.year\#c\.lpc$ = \1, regex) msymbol(S)) (fdi_ppml1_years, label(log Distance) keep(*.year#*.ln_dist) rename(^.*([1-2][0-9][0-9][0-9])\.year\#c\.ln_dist$ = \1, regex) msymbol(T)), vertical name(fdi_ppml1_years, replace) yline(0) xlabel(, ang(45)) ylabel(0, add)

graph export figure\fdi_ppml1_years.png, replace

ppmlhdfe fdi csl cnl lp1 c.lp1#i.year lpc c.lpc#i.year ln_dist c.ln_dist#i.year contig col_dep_ever comcol comrelig comleg_posttrans histwars if(year>=2000)&(un_member_o==1)&(un_member_d==1)&(terrchange_o==0)&(terrchange_d==0)&(col1==0)&(fdi>0), absorb(iso3num_o#year iso3num_d#year) cluster(iso3num_o#iso3num_d)

outreg2 using table\result_fdi_ppml_years, tex(frag) append addtext(Exporter $\times$ Year FE, YES, Importer $\times$ Year FE, YES) nor2 adds(Pseudo R-squared, e(r2_p)) adec(3) label ctitle("PPML ${title2}") sortvar($vars8 $controls)
	
est sto fdi_ppml2_years

coefplot (fdi_ppml2_years, label(LP(Tree)) keep(*.year#*.lp1) rename(^.*([1-2][0-9][0-9][0-9])\.year\#c\.lp1$ = \1, regex)) (fdi_ppml2_years, label(LP(Phonetics)) keep(*.year#*.lpc) rename(^.*([1-2][0-9][0-9][0-9])\.year\#c\.lpc$ = \1, regex) msymbol(S)) (fdi_ppml2_years, label(log Distance) keep(*.year#*.ln_dist) rename(^.*([1-2][0-9][0-9][0-9])\.year\#c\.ln_dist$ = \1, regex) msymbol(T)), vertical name(fdi_ppml2_years, replace) yline(0) xlabel(, ang(45)) ylabel(0, add)

graph export figure\fdi_ppml2_years.png, replace

