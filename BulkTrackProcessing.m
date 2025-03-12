%% come up with list of tracks to read
% 
 


%% Load the dataset for one basin at a time (uncomment the one you want to use)

load ChukCoastSample.mat
TrackDatabase = ChukchiCoastSample;% ChukchiCoast;
clear ChukchiCoastSample;
basin = 'C';
% 
% load BeauCoastSample.mat
% TrackDatabase = BeauCoastSample;
% clear BeauCoastSample;
% basin = 'B';

%% initializing
badtracklist = [];
coastline = shaperead('Coastline2021.shp');
ridges1 = [];
ridges2 = [];
ridges3 = [];

% read in bathymetry
% [A, R] = readgeoraster('GEBCO_AlaskaCoast_bathymetrydata.tif'); % loading in the bathymetric data file
% info = geotiffinfo('GEBCO_AlaskaCoast_bathymetrydata.tif');
% load bathymetry_latlon_grid.mat

Glat = ncread("gebco_2024_n75.0_s66.0_w-175.0_e-135.0.nc", 'lat');
Glon = ncread("gebco_2024_n75.0_s66.0_w-175.0_e-135.0.nc", 'lon');
Gbath = double(ncread("gebco_2024_n75.0_s66.0_w-175.0_e-135.0.nc", 'elevation'));
Gtid = double(ncread("gebco_2024_tid_n75.0_s66.0_w-175.0_e-135.0.nc", 'tid'));

[Glon, Glat] = meshgrid(Glon, Glat);

disp("starting loop")



KeelHigh = [158,188,218]/256;
KeelMid = [140,107,177]/256;
KeelLow = [110,1,107]/256;
Surface = [254,153,41]/256;

PLOTTING = 1;

%%
for n = 1:length(TrackDatabase)
    if TrackDatabase(n).Intersection ~= 'NA'
         
        filename = TrackDatabase(n).name; % only use tracks that intersect shore
        try
        % get the date from the file name
        trackdate = datetime(str2num(filename(7:10)), str2num(filename(11:12)), str2num(filename(13:14)));

        tracklat = TrackDatabase(n).Data(:,2);
        tracklon = TrackDatabase(n).Data(:,1);

        if min(tracklon) < -156.7886
            basin = 'C';
        else
            basin = 'B'; 
        end


        distances_to_coast = distance_sparce(tracklat, tracklon);
        nearcoast = distances_to_coast >0 & distances_to_coast < 4;

        disp('distances')

        %% surface height data and corrections
        fdd_thick = fdd_thickness(trackdate, basin);

        atlheight = TrackDatabase(n).Data(:,4); % pulls surface height data for the track

        % finding the modal surface height

        modalheight = mode(round(atlheight(nearcoast),2));

        % ice thickness from FDD - REPLACE THIS DATE WITH THE DATE OF THE TRACK
        thermodynamic_thickness = fdd_thick /100; %Convert cm to m

        % This is the height in original coordinates of the bottom of the undeformed ice
        bottom_floe_originalcoords = modalheight - thermodynamic_thickness;

        % Now find water level/freeboard
        above_water_floe_thickness = thermodynamic_thickness*(1-(917/1026)); % assuming buoyancy
        waterlevel_originalcoords = modalheight - above_water_floe_thickness;

        % Aligning water level with 0 height 
        surfaceheight = atlheight - waterlevel_originalcoords;
        floe_bottom = bottom_floe_originalcoords - waterlevel_originalcoords;
        corrected_modalfreeboard = modalheight-waterlevel_originalcoords;

        disp('heights')
        %% keel depth calculations

        if basin=='C'
    
            r1 = 3.94 - 1.99;
            r2 = 3.94 ;
            r3 = 3.94 + 1.99;
            int1 = 0;
            int2 = 0;
            int3 = 0;

        elseif basin == 'B'
            r1 = 4.72 - 1.78;
            r2 = 4.72;
            r3 = 4.72 + 1.78;
            int1 = 0;
            int2 = 0;
            int3 = 0;

        end

        % bottom of confidence interval depth estimate
        keeldepth1 = -(r1 * (surfaceheight+above_water_floe_thickness )+int1);
        keeldepth1(keeldepth1>0) = NaN;

        % Top 95% confidence interval
        keeldepth2 = -(r2 * (surfaceheight+above_water_floe_thickness )+int2);
        keeldepth2(keeldepth2>0) = NaN;

        % Linear regression model
        keeldepth3 = -(r3 * (surfaceheight+above_water_floe_thickness )+int3);
        keeldepth3(keeldepth3>0) = NaN;



        % take the max depth between the keel depths and the bottom of thermodynamically grown ice - cleans up plotting
        keeldepth1lower = min(keeldepth1, floe_bottom);
        keeldepth2lower = min(keeldepth2, floe_bottom);
        keeldepth3lower = min(keeldepth3, floe_bottom);

        keeldepthSNOW = -(r3 * (surfaceheight+above_water_floe_thickness + .3 ));
        keeldepthSNOWlower = min(keeldepthSNOW, floe_bottom);
    
         disp('keel depths')
        %% now sample the bathymetry along the lines



        
        bathymetry = interp2(Glon, Glat, Gbath', tracklon, tracklat);
        bathymetryID = interp2(Glon, Glat, Gtid', tracklon, tracklat, 'nearest');

        disp('bathymetry')

    %    save(['debugging_distance_B' num2str(n)], 'bathymetry', 'keeldepth3lower', 'keeldepth2lower', "keeldepth1lower", 'surfaceheight', 'distances_to_coast', 'tracklat', 'tracklon')
    
    %    disp('saved')





        %% plotting
  if PLOTTING       
        figure(n)
        subplot(2, 4, [1 2 3  5 6 7])
        plot(distances_to_coast,surfaceheight, 'Color', Surface)
        hold on
        plot(distances_to_coast, keeldepth1lower, 'Color', KeelHigh)
        plot(distances_to_coast,keeldepth2lower,'Color', KeelMid)
        plot(distances_to_coast,keeldepth3lower,'Color', KeelLow)
        plot(distances_to_coast,bathymetry, 'Color', 'k', 'LineWidth', 2)
        hold off
        grid on

        isobar30m = distances_to_coast(find(bathymetry>-31 & bathymetry< -30, 1));
        if ~isempty(isobar30m)
             upperlim = isobar30m;
        else
            upperlim = max(distances_to_coast);
        end

        if upperlim>100
            upperlim = 100;
        end

        xlim([-1 upperlim])
        xlabel('Distance to shore [km]')
        ylabel('Elevation [m]')

        title([filename; string(trackdate)])

        subplot(2,4,4)
        plot(1, 1, 'Color', Surface)
        hold on
        plot(1,1, 'Color', KeelHigh)
        plot(1,1, 'Color', KeelMid)
        plot(1,1, 'Color', KeelLow)
        plot(1,1, 'Color', 'k')
        hold off
        title(num2str(n))
        legend('corrected surface height', 'Keel Lowest Estimate', 'Keel Highest Estimate', 'Keel Best Estimate', 'Bathymetry', 'location', 'north')


        subplot(2, 4, 8)
        plot(coastline(1).X, coastline(1).Y, '-k');
        hold on
        plot(tracklon, tracklat, '.b')
        hold off
        grid on



        disp('Plotted:')
  else 
      disp('Not plotted:')
  end

        disp(n)
        disp(length(tracklat))
        disp(max(distances_to_coast))
        disp(filename)



%% find grounded ridges 


        keel1 = keeldepth1lower;    
        keel2 = keeldepth2lower;   
        keel3 = keeldepth3lower;   
        keelSNOW = keeldepthSNOWlower;

        keel1(keeldepth1lower > bathymetry | bathymetry < -35 | bathymetry >= -0.5  | bathymetryID == 0) = 5;
        keel2(keeldepth2lower > bathymetry | bathymetry < -35 | bathymetry >= -0.5  | bathymetryID == 0) = 5;
        keel3(keeldepth3lower > bathymetry | bathymetry < -35 | bathymetry >= -0.5  | bathymetryID == 0) = 5;
        keelSNOW(keeldepthSNOWlower > bathymetry | bathymetry < -35 | bathymetry >= -0.5  | bathymetryID == 0) = 5;


        if sum(~isnan(keel1))>5 % make sure there are at least five measurements that cross the threshold

            [~, xsurf1, widths,proms] = findpeaks(surfaceheight, 'MinPeakDistance',200, 'MinPeakProminence', 0.7, 'WidthReference','halfheight', 'MinPeakHeight',0.7); % 100 m separation

            grounded1 = find(keel1<5);
            member1 = ismember(xsurf1, grounded1);
            xkeel1 = xsurf1(member1);

            if length(xkeel1) > 0

            ridges1(n).lat = tracklat(xkeel1);
            ridges1(n).lon = tracklon(xkeel1);
            ridges1(n).bathy = bathymetry(xkeel1);
            ridges1(n).bathid = bathymetryID(xkeel1);
            ridges1(n).surfaceheight = surfaceheight(xkeel1);
            ridges1(n).distance = distances_to_coast(xkeel1);
            ridges1(n).width = widths(member1);
            ridges1(n).proms = proms(member1);
            ridges1(n).date = trackdate;
                         else
                 ridges1(n).lat = [];
            end

        end


        if sum(~isnan(keel2))>5 % make sure there are at least five measurements that cross the threshold


            grounded2 = find(keel2<5);
            member2 = ismember(xsurf1, grounded2);
            xkeel2 = xsurf1(member2);

            if length(xkeel2) > 0

            ridges2(n).lat = tracklat(xkeel2);
            ridges2(n).lon = tracklon(xkeel2);
            ridges2(n).bathy = bathymetry(xkeel2);
            ridges2(n).bathid = bathymetryID(xkeel2);
            ridges2(n).surfaceheight = surfaceheight(xkeel2);
            ridges2(n).distance = distances_to_coast(xkeel2);
            ridges2(n).width = widths(member2);
            ridges2(n).proms = proms(member2);
            ridges2(n).date = trackdate;
                         else
                 ridges2(n).lat = [];
            end

        end

    
          if sum(~isnan(keel3))>5 % make sure there are at least five measurements that cross the threshold      
            
            grounded3 = find(keel3<5);
            member3 = ismember(xsurf1, grounded3);
            xkeel3 = xsurf1(member3);

             if length(xkeel3) > 0

            ridges3(n).lat = tracklat(xkeel3);
            ridges3(n).lon = tracklon(xkeel3);
            ridges3(n).bathy = bathymetry(xkeel3);
            ridges3(n).bathid = bathymetryID(xkeel3);
            ridges3(n).surfaceheight = surfaceheight(xkeel3);
            ridges3(n).distance = distances_to_coast(xkeel3);
            ridges3(n).width = widths(member3);
            ridges3(n).proms = proms(member3);
            ridges3(n).date = trackdate;
            
             else
                 ridges3(n).lat = [];
             end

          end


%% add grounded ridges to plots
 if PLOTTING
   figure(n)
 %  clf;
        subplot(2, 4, [1 2 3  5 6 7])
        hold on
        for m = 1:length(ridges1(n).lat)
            if ridges1(n).bathid(m) < 20
                plot(ridges1(n).distance(m), ridges1(n).bathy(m)-5, '*', 'Color', KeelHigh, 'MarkerSize', 10, 'LineWidth',2)
            elseif ridges1(n).bathid(m) < 50
                plot(ridges1(n).distance(m), ridges1(n).bathy(m)-5, 's', 'Color', KeelHigh,'MarkerSize', 10, 'LineWidth',2)
            else
                plot(ridges1(n).distance(m), ridges1(n).bathy(m)-5, 'd', 'Color', KeelHigh,'MarkerSize', 10, 'LineWidth',2)
            end

        end

         for m = 1:length(ridges2(n).lat)
            if ridges2(n).bathid(m) < 20
                plot(ridges2(n).distance(m), ridges2(n).bathy(m)-10, '*', 'Color', KeelMid, 'MarkerSize', 10, 'LineWidth',2)
            elseif ridges2(n).bathid(m) < 50
                plot(ridges2(n).distance(m), ridges2(n).bathy(m)-10, 's', 'Color', KeelMid,'MarkerSize', 10, 'LineWidth',2)
            else
                plot(ridges2(n).distance(m), ridges2(n).bathy(m)-10, 'd', 'Color', KeelMid,'MarkerSize', 10, 'LineWidth',2)
            end

        end

        for m = 1:length(ridges3(n).lat)
            if ridges3(n).bathid(m) < 20
                plot(ridges3(n).distance(m), ridges3(n).bathy(m)-15, '*', 'Color', KeelLow, 'MarkerSize', 10, 'LineWidth',2)
            elseif ridges3(n).bathid(m) < 50
                plot(ridges3(n).distance(m), ridges3(n).bathy(m)-15, 's', 'Color', KeelLow,'MarkerSize', 10, 'LineWidth',2)
            else
                plot(ridges3(n).distance(m), ridges3(n).bathy(m)-15, 'd', 'Color', KeelLow,'MarkerSize', 10, 'LineWidth',2)
            end

        end

        hold off

       % saving figures
       
        
        savefig(['FIG_' filename(7:41) '.fig'])
        end

        catch
        
        hold off

        disp('error in track')
        disp(n)
        disp(filename)
        badtracklist = [badtracklist n];

       end
    end
end


save('DetectedRidges', 'ridges1', 'ridges2', 'ridges3')