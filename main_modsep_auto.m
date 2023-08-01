% This program is to suppress near zero-time lag noise in CCFs using HLRT.
% Please refer to Luo & Yao et al. (2023), JGR for more details.
% 
% Initial codes by Song Luo, songluo@ustc.edu.cn, released in 2023/8/2

%% Input parameters
clc; clear;

% input directory contains all the cross-correlation functions (CCFs)
indir = './CCFs_original';    

% input station list to run
inloc = './sta_ex.loc';  

% output directory contains the processed CCFs
outdir = 'CCFs_separated';
if~exist(outdir,'dir')
    mkdir(outdir);
end

% read station list file
fid = fopen(inloc,'r');
AAA = textscan(fid,'%s%s%f%f%f');
fclose(fid);
stnm = AAA{1};  nst = length(stnm);

% slowness range for search
pmn = -10; pmx = 10; dp= 0.01;  
p = pmn:dp:pmx; np = length(p);

% define slowness range of signals
plim = [1/5 1/0.1];  % s/km

%% Loop for each virtual source (i.e., each station)
for ist=1:nst
    
    filelist1 = dir([indir,'/ZZ_',stnm{ist},'-','*.SAC']);
    filelist2 = dir([indir,'/ZZ_*','-',stnm{ist},'_','*.SAC']);
    
    filelist = [filelist1;filelist2];
    
    nfile = length(filelist);
    k = 1;
    for i=1:nfile
        disp([i nfile]);
        filename = filelist(i).name;
        sacfile = readsac([indir,'/',filename]);
        if(~isempty(find(isnan(sacfile.DATA1), 1))||isnan(sacfile.DIST)||isnan(sacfile.DELTA)||isnan(sacfile.NPTS))
            continue
        end
        dist(k) = sacfile.DIST;
        seis(:,k) = sacfile.DATA1;
        
        if k==1
            dt = sacfile.DELTA;
            nt = sacfile.NPTS;
            b = sacfile.B;
            t = b:dt:b+(nt-1)*dt;

            dff = 1/(nt*dt);
            ff = 0:dff:(nt-1)*dff;
            f = ff; nf = length(f); df = dff;
            
            flim = [f(1) f(end)];
        end
        
        k = k+1;
    end
    
    % sort the seismograms
    [dist,loc] = sort(dist);
    seis = seis(:,loc);

    % separate signals automatically
    seisr = modsep_auto(f,p,t,dist,seis,flim,plim);
    
    % show the CCFs of one example station
    if ist==1
        figure;
        subplot(1,2,1)
        wigbcc(seis,3,dist,t);
        xlabel('Time (s)');
        ylabel('Distance (km)');
        title('Original CCFs')
        
        subplot(1,2,2)
        wigbcc(seisr,3,dist,t);
        xlabel('Time (s)');
        ylabel('Distance (km)');
        title('Separated CCFs')
    end
    
    % write data
    outdirsub = [outdir,'/',stnm{ist}];
    if~exist(outdirsub,'dir')
        mkdir(outdirsub);
    end
    
    nfile = length(filelist);
    k = 1;
    for i=1:nfile
        disp([i nfile]);
        filename = filelist(i).name;
        sacfile = readsac([indir,'/',filename]);
        if(~isempty(find(isnan(sacfile.DATA1), 1))||isnan(sacfile.DIST)||isnan(sacfile.DELTA)||isnan(sacfile.NPTS))
            continue
        end
        sacfile.FILENAME = [outdirsub,'/',filename];
        sacfile.DATA1 = seisr(:,loc==k);
        writesac(sacfile);
        k = k+1;
    end
end


%% Merge CCFs from the pair of stations

indir = 'CCFs_separated';
outdir = 'CCFs_merged';
if~exist(outdir,'dir')
    mkdir(outdir);
end

filelist = dir([indir,'/*/*.SAC']);
nfile = length(filelist);

clear filename;
for i=1:nfile
    filename{i} = filelist(i).name;
end

filenameu = unique(filename);

nfileu = length(filenameu);
clear coef;
for i=1:nfileu
    disp([i,nfileu]);
    index = find(strcmp(filename,filenameu{i}));
    if length(index)~=2
        continue;
    end
    filepath1 = [filelist(index(1)).folder,'/',filelist(index(1)).name];
    filepath2 = [filelist(index(2)).folder,'/',filelist(index(2)).name];
    
    sacfile = readsac(filepath1); sig1 = sacfile.DATA1;
    sacfile = readsac(filepath2); sig2 = sacfile.DATA1;
    AAA = corrcoef(sig1,sig2);
    coef(i) = AAA(1,2);
    
    if(coef(i)<0.5)
        disp('the following two CCFs have coefficients lower than 0.5:');
        disp(filepath1);
        disp(filepath2);
        continue;
    end

    sig = (sig1+sig2)/2;
    
    sacfile.FILENAME = [outdir,'/',filenameu{i}];
    sacfile.DATA1 = sig;
    writesac(sacfile);    
end

% figure('pos',[500 500 618 1000-618]);
% hist(coef,50);
% xlim([-1 1]);
% xlabel('correlation coefficient');
% ylabel('number of CCFs');
