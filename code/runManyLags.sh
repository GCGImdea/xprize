



ALLCOUNTRIES="AD AE AF AL AO AR AT AU AW AZ BA BB BD BE BF BG BH BI BJ BM BN BO BR BS BT BW BY BZ CA CD CF CG CH CI CL CM CN CO CR CU CV CY CZ DE DJ DK DM DO DZ EC EE EG ER ES ET FI FJ FO FR GA GB GE GH GL GM GN GR GT GU GY HK HN HR HT HU ID IE IL IN IQ IR IS IT JM JO JP KE KG KH KM KR KW KZ LA LB LK LR LS LT LU LV LY MA MC MD MG ML MM MN MO MR MU MW MX MY MZ NA NE NG NI NL NO NP NZ OM PA PE PG PH PK PL PR PS PT PY QA RO RS RU RW SA SB SC SD SE SG SI SK SL SM SN SO SR SS SV SY SZ TD TG TH TJ TL TN TR TT TW TZ UA UG US UY UZ VE VN VU XK YE ZA ZM ZW"
#COUNTRIESTODO='"PT"'
for COUNTRY in $ALLCOUNTRIES; do
    COUNTRIESTODO="\"$COUNTRY\""
    echo $COUNTRIESTODO
for LIMRANGE in TRUE; do 
for PEN in FALSE; do
    for ALPHA in 0.5; do
	for RMCL in TRUE; do
	    for RMTH in 0.9; do
		for MILAG in 3 7 14 22; do
		    for MXLAG in 60 ; do
			for SIGTOMATCH in cases ; do
			    for SIGTOTRY in ox_data-owid_data-gmob_data ox_data-owid_data ox_data-owid_data-gmob_data-umdapi_data-cmu_data; do 
				for FIRSTCUTOFF in 2020-11-30; do
				    for LASTCUTOFF in 2020-12-21; do
					for CUTOFFINTERVAL in 1 ; do
					    for SMOOTH in FALSE ; do 
						for BASISDIM in 15 ; do
						    sed "s/#PEN#/$PEN/g" runlag.R | sed  "s/#LIMRANGE#/$LIMRANGE/g" | sed  "s/#ALPHA#/$ALPHA/g" | sed  "s/#RMCL#/$RMCL/g" | sed  "s/#RMTH#/$RMTH/g" | sed  "s/#MILAG#/$MILAG/g"| sed  "s/#MXLAG#/$MXLAG/g"| sed  "s/#SIGTOMATCH#/$SIGTOMATCH/g"    | sed  "s/#SIGTOTRY#/$SIGTOTRY/g" | sed  "s/#FIRSTCUTOFF#/$FIRSTCUTOFF/g"| sed  "s/#LASTCUTOFF#/$LASTCUTOFF/g" | sed  "s/#CUTOFFINTERVAL#/$CUTOFFINTERVAL/g"| sed  "s/#COUNTRIESTODO#/$COUNTRIESTODO/g" | sed "s/#SMOOTH#/$SMOOTH/g" |sed "s/#BASISDIM#/$BASISDIM/g" > runlag-$COUNTRY-pen$PEN$ALPHA-rmcl$RMCL$RMTH-smooth$SMOOTH$BASISDIM-limrange$LIMRANGE-lag$MILAG-$MXLAG-$SIGTOMATCH-$SIGTOTRY-$FIRSTCUTOFF-$LASTCUTOFF-$CUTOFFINTERVAL.R
						    Rscript runlag-$COUNTRY-pen$PEN$ALPHA-rmcl$RMCL$RMTH-smooth$SMOOTH$BASISDIM-limrange$LIMRANGE-lag$MILAG-$MXLAG-$SIGTOMATCH-$SIGTOTRY-$FIRSTCUTOFF-$LASTCUTOFF-$CUTOFFINTERVAL.R  > runlag-$COUNTRY-pen$PEN$ALPHA-rmcl$RMCL$RMTH-smooth$SMOOTH$BASISDIM-limrange$LIMRANGE-lag$MILAG-$MXLAG-$SIGTOMATCH-$SIGTOTRY-$FIRSTCUTOFF-$LASTCUTOFF-$CUTOFFINTERVAL.Rout 2>&1 &
						done
					    done 
					done
				    done
				done
			    done
			done
		    done
		done
	    done
	done
    done
done
done
done
					    
					   
#PEN# 
#ALPHA#
#RMCL# 
#RMTH# 

#MILAG#
#MXLAG#
#SIGTOMATCH#
#SIGTOTRY#

#FIRSTCUTOFF#
#LASTCUTOFF#
#CUTOFFINTERVAL#


