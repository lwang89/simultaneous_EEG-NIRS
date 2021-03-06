% This MATLAB script can be used to reproduce the hemodynamic response in dataset C (Figure 11)
% Please download BBCItoolbox to 'MyToolboxDir'
% Please download dataset to 'NirsMyDataDir' and 'EegMyDataDir'
% The authors would be grateful if published reports of research using this code
% (or a modified version, maintaining a significant portion of the original code) would cite the following article:
% Shin et al. "Simultaneous acquisition of EEG and NIRS during cognitive tasks for an open access dataset",
% Scientific data (2017), under review.
% NOTE: Figure may be different from that shown in Shin et al. (2017) because EOG-rejection is not performed.

clear all; clc; close all;

%%%%%%%%%%%%%%%%%%%%%%%% modify directory paths properly %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MyToolboxDir = fullfile('C:','Users','shin','Documents','MATLAB','bbci_public-master');
MyToolboxDir = fullfile('C:','Users','shin','Documents','MATLAB','bbci_toolbox_latest_ver');
WorkingDir = fullfile('C:','Users','shin','Documents','MATLAB','scientific_data');
NirsMyDataDir = fullfile('F:','scientific_data_publish','rawdata','NIRS');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cd(MyToolboxDir);
startup_bbci_toolbox('DataDir',NirsMyDataDir,'TmpDir','/tmp/','History',0);
cd(WorkingDir);

addpath(genpath(pwd));

%%%%%%%%%%%%%%%%% initial parameter %%%%%%%%%%%%%%%%%
subdir_list = {'VP001-NIRS','VP002-NIRS','VP003-NIRS','VP004-NIRS','VP005-NIRS','VP006-NIRS','VP007-NIRS','VP008-NIRS','VP009-NIRS','VP010-NIRS','VP011-NIRS','VP012-NIRS','VP013-NIRS','VP014-NIRS','VP015-NIRS','VP016-NIRS','VP017-NIRS','VP018-NIRS','VP019-NIRS','VP020-NIRS','VP021-NIRS','VP022-NIRS','VP023-NIRS','VP024-NIRS','VP025-NIRS','VP026-NIRS'};
ival_epo  = [-5 25]*1000; % epoch range (unit: msec)
ival_base = [-5 -2]*1000; % baseline correction range (unit: msec)
ylim = [-8 8]*1e-4;
clim = [-10 10];
ival_scalp = [0 5; 5 10; 10 15; 15 20; 20 25]*1000;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Load NIRS data
for vp = 1 : length(subdir_list)
    disp([subdir_list{vp}, ' was started']);
    loadDir = fullfile(NirsMyDataDir,subdir_list{vp});
    cd(loadDir);
    load cnt_wg; load mrk_wg; load mnt_wg;
    cd(WorkingDir);
    
    mrk_wg.className = {'WG','BL'};
      
    % low-pass filter
    [b,a] = butter(3, 0.2/cnt_wg.deoxy.fs*2, 'low');
    cnt_wg.deoxy = proc_filtfilt(cnt_wg.deoxy, b, a);
    cnt_wg.oxy   = proc_filtfilt(cnt_wg.oxy, b, a);
    
    % segmentation
    epo.deoxy = proc_segmentation(cnt_wg.deoxy, mrk_wg, ival_epo);
    epo.oxy   = proc_segmentation(cnt_wg.oxy, mrk_wg, ival_epo);
   
    % Add unit of x- and y-axis
    epo.deoxy.xUnit = 's';
    epo.deoxy.yUnit = 'mmol/L';
    epo.oxy.xUnit = 's';
    epo.oxy.yUnit = 'mmol/L';
    
    if vp == 1
        epo_all.deoxy = epo.deoxy;
        epo_all.oxy   = epo.oxy;
    else
        epo_all.deoxy = proc_appendEpochs(epo_all.deoxy, epo.deoxy);
        epo_all.oxy   = proc_appendEpochs(epo_all.oxy,   epo.oxy);
    end
    
end

%% Baseline correction
epo_all.deoxy = proc_baseline(epo_all.deoxy, ival_base);
epo_all.oxy   = proc_baseline(epo_all.oxy, ival_base);

%% Dimensionality correction
epo_all.deoxy.t = epo_all.deoxy.t(:,:,1);
epo_all.oxy.t = epo_all.oxy.t(:,:,1);

%% Trial-Average
epo_all.deoxy = proc_average(epo_all.deoxy, 'Stats', 1);
epo_all.oxy   = proc_average(epo_all.oxy, 'Stats', 1);

%% Plot figures
fig_set(3, 'Toolsoff', 0, 'Resize', [1 1.3])
H= plot_scalpEvolutionPlusChannel(epo_all.deoxy, mnt_wg, {'AFp7','FCC3'}, ival_scalp, defopt_scalp_erp, 'GlobalCLim', 0, 'Extrapolation', 0, 'Contour', 0, 'printival', 1, 'Colormap', cmap_posneg(101), 'ColorOrder', [36 120 255; 0 12 183]/255, 'PlotStd', 1, 'yLim', ylim, 'PlotStat', 'sem');

fig_set(4, 'Toolsoff', 0, 'Resize', [1 1.3])
H= plot_scalpEvolutionPlusChannel(epo_all.oxy, mnt_wg, {'AFp7','FCC3'}, ival_scalp, defopt_scalp_erp, 'GlobalCLim', 0, 'Extrapolation', 0, 'Contour', 0, 'printival', 1, 'Colormap', cmap_posneg(101), 'ColorOrder', [242 150 97; 255 0 0]/255, 'PlotStd', 1, 'yLim', ylim, 'PlotStat', 'sem');



