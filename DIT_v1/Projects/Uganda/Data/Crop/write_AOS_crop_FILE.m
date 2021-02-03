function write_AOS_crop_FILE(filename,PlantDate,HarvDate)

%Open the AquaCrop file
filetype  'txt';
fullfile = strcat(filename,'.',filetype);
fID_AQ = fopen(fullfile,'r');

%Open the AOS file to write to
new_AOS = strcat('AOS_Crop_',filename,'.',filetype);
fID_AOS = fopen(new_AOS,'wt');

%Get information from AquaCrop file
%% Crop Type ('1': Leafy vegetable, '2': Root/tuber, '3': Fruit/grain) %%
linenum = 4;    %2 = fruit/grain, 
CropTYPE = AQ_Crop(fID_AQ,linenum);
if CropTYPE == 2
    CropType = 3;
end
%% Calendar Type ('1': Calendar days, '2': Growing degree days)
linenum = 6;    % = Growing degree days
CalendarTYPE = AQ_Crop(fID_AQ,linenum);
if CalendarTYPE == 0
    CalendarType = 2;
else
    CalendarType = 1;
end
%% Convert calendar to GDD mode if inputs are given in calendar days ('0': No; '1': Yes) %%
SwitchGDD = 1;
%% Planting Date (dd/mm) %%
PlantingDate = PlantDate; %01/11
%% Latest Harvest Date (dd/mm) %%
HarvestDate = HarvDate; %01/03
%% Growing degree/Calendar days from sowing to emergence/transplant recovery %%
linenum = 69;
Emergence = AQ_Crop(fID_AQ,linenum);
%% Growing degree/Calendar days from sowing to maximum rooting %%
linenum = 70;
MaxRooting = AQ_Crop(fID_AQ,linenum);
%% Growing degree/Calendar days from sowing to senescence %%
linenum = 71;
Senescence = AQ_Crop(fID_AQ,linenum);
%% Growing degree/Calendar days from sowing to maturity %%
linenum = 72;
Maturity = AQ_Crop(fID_AQ,linenum);
%% Growing degree/Calendar days from sowing to start of yield formation %%
linenum = 73;
HIstart = AQ_Crop(fID_AQ,linenum);
%% Duration of flowering in growing degree/calendar days (-999 for non-fruit/grain crops) %%
linenum = 74;
Flowering = AQ_Crop(fID_AQ,linenum);
%% Duration of yield formation in growing degree/calendar days %%
linenum = 77;
YldForm = AQ_Crop(fID_AQ,linenum);
%% Growing degree day calculation method %%
%linenum = ???
GDDmethod = 2;
%% Base temperature (degC) below which growth does not progress %%
linenum = 8;
Tbase = AQ_Crop(fID_AQ,linenum);
%% Upper temperature (degC) above which crop development no longer increases %%
linenum = 9;
Tupp = AQ_Crop(fID_AQ,linenum);
%% Pollination affected by heat stress (0= No; 1= Yes) %%
%linenum = ???;
PolHeatStress = 1;
%% Maximum air temperature (degC) above which pollination begins to fail %%
linenum = 28;
Tmax_up = AQ_Crop(fID_AQ,linenum);
%% Maximum air temperature (degC) at which pollination completely fails %%
%linenum = ???;9
Tmax_lo = 45;
%% Pollination affected by cold stress (0= No; 1= Yes) %%
%linenum = ???;
PolColdStress = 1;
%% Minimum air temperature (degC) below which pollination begins to fail %%
linenum = 27;
Tmin_up = AQ_Crop(fID_AQ,linenum);
%% Minimum air temperature (degC) at which pollination completely fails %%
%linenum = ???;8
Tmin_lo = 5;
%% Biomass production affected by temperature stress (0= No; 1= Yes) %%
%linenum = ???;
BioTempStress = 1;
%% Minimum growing degree days (degC/day) required for full biomass production %%
linenum = 29;
GDD_up = AQ_Crop(fID_AQ,linenum);
%% Growing degree days (degC/day) at which no biomass production occurs %%
%linenum = ???;
GDD_lo = 0;
%% Shape factor describing the reduction in biomass production for insufficient growing degree days %%
%linenum = ???;
fshape_b = 13.8135
%% Initial percentage of minimum effective rooting depth %%
%linenum = 
PctZmin = 70
%% Minimum effective rooting depth (m) %%
linenum = 37;
Zmin = AQ_Crop(fID_AQ,linenum);
%% Maximum rooting depth (m) %%
linenum = 38;
Zmax = AQ_Crop(fID_AQ,linenum);
%% Shape factor describing root expansion %%
linenum = 39;    %13 versus AOS version 1.3?
fshape_r = AQ_Crop(fID_AQ,linenum);
%% Shape factor describing the effects of water stress on root expansion %%
%linenum = ???;
fshape_ex = -6;
%% Maximum root water extraction at top of the root zone (m3/m3/day) %%
linenum = 40;
SxTopQ = AQ_Crop(fID_AQ,linenum);
%% Maximum root water extraction at the bottom of the root zone (m3/m3/day) %%
linenum = 41;
SxBotQ = AQ_Crop(fID_AQ,linenum);
%% Exponent parameter for adjustment of Kcx once senescence is triggered %%
%linenum = ???;18
a_Tr = 1;
%% Soil surface area (cm2) covered by an individual seedling at 90% emergence %%
linenum = 43;
SeedSize = AQ_Crop(fID_AQ,linenum);
%% Number of plants per hectare %%
linenum = 45;
PlantPop = AQ_Crop(fID_AQ,linenum);
%% Minimum canopy size below which yield formation cannot occur %%
%linenum = 
CCmin = 0.049;
%% Maximum canopy cover (fraction of soil cover) %%
linenum = 50;
CCx = AQ_Crop(fID_AQ,linenum);
%% Canopy decline coefficient (fraction per day/GDD) %%
linenum = 51;
CDC = AQ_Crop(fID_AQ,linenum);
%% Canopy growth coefficient (fraction per day/GDD) %%
linenum = 46;
CGC = AQ_Crop(fID_AQ,linenum);
%% Crop coefficient when canopy growth is complete but prior to senescence %%
linenum = 35;
Kcb = AQ_Crop(fID_AQ,linenum);
%% Decline of crop coefficient due to ageing (%/day) %%
linenum = 36;
fage = AQ_Crop(fID_AQ,linenum);
%% Water productivity normalized for ET0 and C02 (g/m2) %%
linenum = 61;
WP = AQ_Crop(fID_AQ,linenum);
%% Adjustment of water productivity in yield formation stage (% of WP) %%
linenum = 62;
WPy = AQ_Crop(fID_AQ,linenum);
%% Crop co2 sink strength coefficient %%
linenum = 63; %63?/100
fsink = AQ_Crop(fID_AQ,linenum);
fsink = num2str(str2num(fsink)/100);
%% WP co2 adjustment parameter given by Steduto et al. 2007 %%
%linenum = ???;
bsted = 0.000138;
%% WP co2 adjustment parameter given by FACE experiments %%
%linenum = ???;
bface = 0.001165;
%% Reference harvest index %%
linenum = 64; % change to decimal
HI0 = AQ_Crop(fID_AQ,linenum);
%% Initial harvest index %%
%linenum = ???;
HIini = 0.01;
%% Possible increase of harvest index due to water stress before flowering (%) %%
linenum = 65;
dHI_pre = AQ_Crop(fID_AQ,linenum);
%% Coefficient describing positive impact on harvest index of restricted vegetative growth during yield formation %%
linenum = 66;
a_HI = AQ_Crop(fID_AQ,linenum);
%% Coefficient describing negative impact on harvest index of stomatal closure during yield formation %%
linenum = 67;
b_HI = AQ_Crop(fID_AQ,linenum);
%% Maximum allowable increase of harvest index above reference %%
linenum = 68;
dHI0 = AQ_Crop(fID_AQ,linenum);
%% Crop Determinancy ('0'= Indeterminant, '1'= Determinant) %%
linenum = 58;
Determinant = AQ_Crop(fID_AQ,linenum);
%% Excess of potential fruits %%
linenum = 59;
exc = AQ_Crop(fID_AQ,linenum);
%% Percentage of total flowering at which peak flowering occurs %%
linenum = ???;
MaxFlowPct = 33.33
%% Upper soil water depletion threshold for water stress effects on affect canopy expansion %%
linenum = 11;
p_up1 = AQ_Crop(fID_AQ,linenum);
%% Upper soil water depletion threshold for water stress effects on canopy stomatal control %%
linenum = 15;
p_up2 = AQ_Crop(fID_AQ,linenum);
%% Upper soil water depletion threshold for water stress effects on canopy senescence %%
linenum = 17;
p_up3 = AQ_Crop(fID_AQ,linenum);
%% Upper soil water depletion threshold for water stress effects on canopy pollination %%
linenum = 19;
p_up4 = AQ_Crop(fID_AQ,linenum);
%% Lower soil water depletion threshold for water stress effects on canopy expansion %%
linenum = 12
p_lo1 = AQ_Crop(fID_AQ,linenum);
%% Lower soil water depletion threshold for water stress effects on canopy stomatal control %%
linenum = ???;
p_lo2 = 1
%% Lower soil water depletion threshold for water stress effects on canopy senescence %%
linenum = ???;
p_lo3 = 1
%% Lower soil water depletion threshold for water stress effects on canopy pollination %%
linenum = ???;
p_lo4 = 1
%% Shape factor describing water stress effects on canopy expansion %%
linenum = 13;
fshape_w1 = AQ_Crop(fID_AQ,linenum);
%% Shape factor describing water stress effects on stomatal control %%
linenum = 15;
fshape_w2 = AQ_Crop(fID_AQ,linenum);
%% Shape factor describing water stress effects on canopy senescence %%
linenum = 17;
fshape_w3 = AQ_Crop(fID_AQ,linenum);
%% Shape factor describing water stress effects on pollination %%
linenum = ???;
fshape_w4 = 1
%% Adjustment to water stress thresholds depending on daily ET0 (0= 'No', 1= 'Yes') %%
linenum = 
ETadj = 1
%% Vol (%) below saturation at which stress begins to occur due to deficient aeration %%
linenum = 20;
Aer = AQ_Crop(fID_AQ,linenum);
%% Number of days lag before aeration stress affects crop growth %%
linenum = 
LagAer = 3
%% Reduction (%) to p_lo3 when early canopy senescence is triggered %%
linenum = 
beta = 12
%% Proportion of total water storage needed for crop to germinate %%
linenum = 
GermThr = 0.2

fclose(fID_AQ); %Close the AquaCrop file


%% Copy over the information from the AquaCrop file to the AOS file
fprintf(fID_AOS,'%% ---------- Crop parameters for AquaCropOS ---------- %%\n');
fprintf(fID_AOS,'%% Crop Type (''1'': Leafy vegetable, ''2'': Root/tuber, ''3'': Fruit/grain) %%\n');
fprintf(fID_AOS,strcat('CropType : ',CropType,'\n'));
fprintf(fID_AOS,'%% Calendar Type (''1'': Calendar days, ''2'': Growing degree days)\n');
fprintf(fID_AOS,strcat('CalendarType : ',CalendarType,'\n'));
fprintf(fID_AOS,'%% Convert calendar to GDD mode if inputs are given in calendar days ('0': No; '1': Yes) %%\n');
fprintf(fID_AOS,strcat('SwitchGDD : ',SwitchGDD,'\n'));
fprintf(fID_AOS,'%% Planting Date (dd/mm) %%\n');
fprintf(fID_AOS,strcat('PlantingDate : ',PlantingDate,'\n'));
fprintf(fID_AOS,'%% Latest Harvest Date (dd/mm) %%\n');
fprintf(fID_AOS,strcat('HarvestDate : ',HarvestDate,'\n'));
fprintf(fID_AOS,'%% Growing degree/Calendar days from sowing to emergence/transplant recovery %%\n');
fprintf(fID_AOS,strcat('Emergence : ',Emergence,'\n'));
fprintf(fID_AOS,'%% Growing degree/Calendar days from sowing to maximum rooting %%\n');
fprintf(fID_AOS,strcat('MaxRooting : ',MaxRooting,'\n'));
fprintf(fID_AOS,'%% Growing degree/Calendar days from sowing to senescence %%\n');
fprintf(fID_AOS,strcat('Senescence : ',Senescence,'\n'));
fprintf(fID_AOS,'%% Growing degree/Calendar days from sowing to maturity %%\n');
fprintf(fID_AOS,strcat('Maturity : ',Maturity,'\n'));
fprintf(fID_AOS,'%% Growing degree/Calendar days from sowing to start of yield formation %%\n');
fprintf(fID_AOS,strcat('HIstart : ',HIstart,'\n'));
fprintf(fID_AOS,'%% Duration of flowering in growing degree/calendar days (-999 for non-fruit/grain crops) %%\n');
fprintf(fID_AOS,strcat('Flowering : ',Flowering,'\n'));
fprintf(fID_AOS,'%% Duration of yield formation in growing degree/calendar days %%\n');
fprintf(fID_AOS,strcat('YldForm : ',YldForm,'\n'));
fprintf(fID_AOS,'%% Growing degree day calculation method %%\n');
fprintf(fID_AOS,strcat('GDDmethod : ',GDDmethod,'\n'));
fprintf(fID_AOS,'%% Base temperature (degC) below which growth does not progress %%\n');
fprintf(fID_AOS,strcat('Tbase : ',Tbase,'\n'));
fprintf(fID_AOS,'%% Upper temperature (degC) above which crop development no longer increases %%\n');
fprintf(fID_AOS,strcat('Tupp : ',Tupp,'\n'));
fprintf(fID_AOS,'%% Pollination affected by heat stress (0: No; 1: Yes) %%\n');
fprintf(fID_AOS,strcat('PolHeatStress : ',PolHeatStress,'\n'));
fprintf(fID_AOS,'%% Maximum air temperature (degC) above which pollination begins to fail %%\n');
fprintf(fID_AOS,strcat('Tmax_up : ',Tmax_up,'\n'));
fprintf(fID_AOS,'%% Maximum air temperature (degC) at which pollination completely fails %%\n');
fprintf(fID_AOS,strcat('Tmax_lo : ',Tmax_lo,'\n'));
fprintf(fID_AOS,'%% Pollination affected by cold stress (0: No; 1: Yes) %%\n');
fprintf(fID_AOS,strcat('PolColdStress : ',PolColdStress,'\n'));
fprintf(fID_AOS,'%% Minimum air temperature (degC) below which pollination begins to fail %%\n');
fprintf(fID_AOS,strcat('Tmin_up : ',Tmin_up,'\n'));
fprintf(fID_AOS,'%% Minimum air temperature (degC) at which pollination completely fails %%\n');
fprintf(fID_AOS,strcat('Tmin_lo : ',Tmin_lo,'\n'));
fprintf(fID_AOS,'%% Biomass production affected by temperature stress (0: No; 1: Yes) %%\n');
fprintf(fID_AOS,strcat('BioTempStress : ',BioTempStress,'\n'));
fprintf(fID_AOS,'%% Minimum growing degree days (degC/day) required for full biomass production %%\n');
fprintf(fID_AOS,strcat('GDD_up : ',GDD_up,'\n'));
fprintf(fID_AOS,'%% Growing degree days (degC/day) at which no biomass production occurs %%\n');
fprintf(fID_AOS,strcat('GDD_lo : ',GDD_lo,'\n'));
fprintf(fID_AOS,'%% Shape factor describing the reduction in biomass production for insufficient growing degree days %%\n');
fprintf(fID_AOS,strcat('fshape_b : ',fshape_b,'\n'));
fprintf(fID_AOS,'%% Initial percentage of minimum effective rooting depth %%\n');
fprintf(fID_AOS,strcat('PctZmin : ',PctZmin,'\n'));
fprintf(fID_AOS,'%% Minimum effective rooting depth (m) %%\n');
fprintf(fID_AOS,strcat('Zmin : ',Zmin,'\n'));
fprintf(fID_AOS,'%% Maximum rooting depth (m) %%\n');
fprintf(fID_AOS,strcat('Zmax : ',Zmax,'\n'));
fprintf(fID_AOS,'%% Shape factor describing root expansion %%\n');
fprintf(fID_AOS,strcat('fshape_r : ',fshape_r,'\n'));
fprintf(fID_AOS,'%% Shape factor describing the effects of water stress on root expansion %%\n');
fprintf(fID_AOS,strcat('fshape_ex : ',fshape_ex,'\n'));
fprintf(fID_AOS,'%% Maximum root water extraction at top of the root zone (m3/m3/day) %%\n');
fprintf(fID_AOS,strcat('SxTopQ : ',Sx,'\n'));
fprintf(fID_AOS,'%% Maximum root water extraction at the bottom of the root zone (m3/m3/day) %%\n');
fprintf(fID_AOS,strcat('SxBotQ : ',SxBotQ,'\n'));
fprintf(fID_AOS,'%% Exponent parameter for adjustment of Kcx once senescence is triggered %%\n');
fprintf(fID_AOS,strcat('a_Tr : ',a_Tr,'\n'));
fprintf(fID_AOS,'%% Soil surface area (cm2) covered by an individual seedling at 90% emergence %%\n');
fprintf(fID_AOS,strcat('SeedSize : ',SeedSize,'\n'));
fprintf(fID_AOS,'%% Number of plants per hectare %%\n');
fprintf(fID_AOS,strcat('PlantPop : ',PlantPop,'\n'));
fprintf(fID_AOS,'%% Minimum canopy size below which yield formation cannot occur %%\n');
fprintf(fID_AOS,strcat('CCmin : ',CCmin,'\n'));
fprintf(fID_AOS,'%% Maximum canopy cover (fraction of soil cover) %%\n');
fprintf(fID_AOS,strcat('CCx : ',CCx,'\n'));
fprintf(fID_AOS,'%% Canopy decline coefficient (fraction per day/GDD) %%\n');
fprintf(fID_AOS,strcat('CDC : ',CDC,'\n'));
fprintf(fID_AOS,'%% Canopy growth coefficient (fraction per day/GDD) %%\n');
fprintf(fID_AOS,strcat('CGC : ',CGC,'\n'));
fprintf(fID_AOS,'%% Crop coefficient when canopy growth is complete but prior to senescence %%\n');
fprintf(fID_AOS,strcat('Kcb : ',Kcb,'\n'));
fprintf(fID_AOS,'%% Decline of crop coefficient due to ageing (%/day) %%\n');
fprintf(fID_AOS,strcat('fage : ',fage,'\n'));
fprintf(fID_AOS,'%% Water productivity normalized for ET0 and C02 (g/m2) %%\n');
fprintf(fID_AOS,strcat('WP : ',WP,'\n'));
fprintf(fID_AOS,'%% Adjustment of water productivity in yield formation stage (% of WP) %%\n');
fprintf(fID_AOS,strcat('WPy : ',WPy,'\n'));
fprintf(fID_AOS,'%% Crop co2 sink strength coefficient %%\n');
fprintf(fID_AOS,strcat('fsink : ',fsink,'\n'));
fprintf(fID_AOS,'%% WP co2 adjustment parameter given by Steduto et al. 2007 %%\n');
fprintf(fID_AOS,strcat('bsted : ',bsted,'\n'));
fprintf(fID_AOS,'%% WP co2 adjustment parameter given by FACE experiments %%\n');
fprintf(fID_AOS,strcat('bface : ',bface,'\n'));
fprintf(fID_AOS,'%% Reference harvest index %%\n');
fprintf(fID_AOS,strcat('HI0 : ',HI0,'\n'));
fprintf(fID_AOS,'%% Initial harvest index %%\n');
fprintf(fID_AOS,strcat('HIini : ',HIini,'\n'));
fprintf(fID_AOS,'%% Possible increase of harvest index due to water stress before flowering (%) %%\n');
fprintf(fID_AOS,strcat('dHI_pre : ',dHI_pre,'\n'));
fprintf(fID_AOS,'%% Coefficient describing positive impact on harvest index of restricted vegetative growth during yield formation %%\n');
fprintf(fID_AOS,strcat('a_HI : ',a_HI,'\n'));
fprintf(fID_AOS,'%% Coefficient describing negative impact on harvest index of stomatal closure during yield formation %%\n');
fprintf(fID_AOS,strcat('b_HI : ',b_HI,'\n'));
fprintf(fID_AOS,'%% Maximum allowable increase of harvest index above reference %%\n');
fprintf(fID_AOS,strcat('dHI0 : ',dHI0,'\n'));
fprintf(fID_AOS,'%% Crop Determinancy (''0'': Indeterminant, ''1'': Determinant) %%\n');
fprintf(fID_AOS,strcat('Determinant : ',Determinant,'\n'));
fprintf(fID_AOS,'%% Excess of potential fruits %%\n');
fprintf(fID_AOS,strcat('exc : ',exc,'\n'));
fprintf(fID_AOS,'%% Percentage of total flowering at which peak flowering occurs %%\n');
fprintf(fID_AOS,strcat('MaxFlowPct : ',MaxFlowPct,'\n'));
fprintf(fID_AOS,'%% Upper soil water depletion threshold for water stress effects on affect canopy expansion %%\n');
fprintf(fID_AOS,strcat('p_up1 : ',p_up1,'\n'));
fprintf(fID_AOS,'%% Upper soil water depletion threshold for water stress effects on canopy stomatal control %%\n');
fprintf(fID_AOS,strcat('p_up2 : ',p_up2,'\n'));
fprintf(fID_AOS,'%% Upper soil water depletion threshold for water stress effects on canopy senescence %%\n');
fprintf(fID_AOS,strcat('p_up3 : ',p_up3,'\n'));
fprintf(fID_AOS,'%% Upper soil water depletion threshold for water stress effects on canopy pollination %%\n');\n');
fprintf(fID_AOS,strcat('p_up4 : ',p_up4,'\n'));
fprintf(fID_AOS,'%% Lower soil water depletion threshold for water stress effects on canopy expansion %%\n');
fprintf(fID_AOS,strcat('p_lo1 : ',p_lo1,'\n'));
fprintf(fID_AOS,'%% Lower soil water depletion threshold for water stress effects on canopy stomatal control %%\n');
fprintf(fID_AOS,strcat('p_lo2 : ',p_lo2,'\n'));
fprintf(fID_AOS,'%% Lower soil water depletion threshold for water stress effects on canopy senescence %%\n');
fprintf(fID_AOS,strcat('p_lo3 : ',p_lo3,'\n'));
fprintf(fID_AOS,'%% Lower soil water depletion threshold for water stress effects on canopy pollination %%\n');
fprintf(fID_AOS,strcat('p_lo4 : ',p_lo4,'\n'));
fprintf(fID_AOS,'%% Shape factor describing water stress effects on canopy expansion %%\n');
fprintf(fID_AOS,strcat('fshape_w1 : ',fshape_w1,'\n'));
fprintf(fID_AOS,'%% Shape factor describing water stress effects on stomatal control %%\n');
fprintf(fID_AOS,strcat('fshape_w2 : ',fshape_w2,'\n'));
fprintf(fID_AOS,'%% Shape factor describing water stress effects on canopy senescence %%\n');
fprintf(fID_AOS,strcat('fshape_w3 : ',fshape_w3,'\n'));
fprintf(fID_AOS,'%% Shape factor describing water stress effects on pollination %%\n');
fprintf(fID_AOS,strcat('fshape_w4 : ',fshape_w4,'\n'));
fprintf(fID_AOS,'%% Adjustment to water stress thresholds depending on daily ET0 (0: ''No'', 1: ''Yes'') %%\n');
fprintf(fID_AOS,strcat('ETadj : ',ETadj,'\n'));
fprintf(fID_AOS,'%% Vol (%) below saturation at which stress begins to occur due to deficient aeration %%\n');
fprintf(fID_AOS,strcat('Aer : ',Aer,'\n'));
fprintf(fID_AOS,'%% Number of days lag before aeration stress affects crop growth %%\n');
fprintf(fID_AOS,strcat('LagAer : ',LagAer,'\n'));
fprintf(fID_AOS,'%% Reduction (%) to p_lo3 when early canopy senescence is triggered %%\n');
fprintf(fID_AOS,strcat('beta : ',beta,'\n'));
fprintf(fID_AOS,'%% Proportion of total water storage needed for crop to germinate %%\n');
fprintf(fID_AOS,strcat('GermThr : ',GermThr,'\n'));

fclose(fID_AOS);    %Close the AquaCropOS file
end

function CropINFO = AQ_Crop(fileID,linenum)
    %% Read the File
    crop_data = textscan(fileID,'%f',1,'Delimiter','space','headerlines',linenum-1); %Scan the last row 
    CropINFO = crop_data{1,1};              %[tons/hect] 
end