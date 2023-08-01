
clear;

% Mianning_surface
indir = './sac_selected';  % input directory contains all the cross-correlation functions (CCFs)
% inloc = './sta_selected.loc';  % sall stations to run
inloc = './sta_tmp.loc';  % example stations to run

% read station list file
fid = fopen(inloc,'r');
AAA = textscan(fid,'%s%s%f%f%f');
fclose(fid);
stnm = AAA{1};  nst = length(stnm);

pmn = -10; pmx = 10; dp= 0.01;  % slowness range for search
p = pmn:dp:pmx; np = length(p);

plim = [1/5 1/0.1]; % define slowness range of signals

% for each virtual source (i.e., each station)
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
        cor = sacfile.DATA1;
        dt = sacfile.DELTA;
        L = sacfile.NPTS;
        b = sacfile.B;
        nt = (L+1)/2;
        %     seis(:,k) = (cor(nt:end)+cor(nt:-1:1))/2;
        seis(:,k) = cor; nt = L;
        k = k+1;
    end
    % t = 0:dt:(nt-1)*dt;
    t = b:dt:b+(nt-1)*dt;
    
    ntrace = size(seis,2);
    
    % sort the seismograms
    [dist,loc] = sort(dist);
    seis = seis(:,loc);
    
    mm = nt;
    dff = 1/(mm*dt);
    ff = 0:dff:(mm-1)*dff;
    f = ff; nf = length(f); df = dff;
    flim = [f(1) f(end)];
    
    % separate signals automatically
    seisr = modsep_auto(f,p,t,dist,seis,flim,plim);
    
%     figure;
%     wigb(seis(:,1:1:end));
%     
%     figure;
%     wigb(seisr(:,1:1:end));
    
    %% write data
    outdir = 'COR_Mianning_surface';
    if~exist(outdir,'dir')
        mkdir(outdir);
    end
    outdir = [outdir,'/',stnm{ist}];
    if~exist(outdir,'dir')
        mkdir(outdir);
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
        sacfile.FILENAME = [outdir,'/',filename];
        sacfile.DATA1 = seisr(:,loc==k);
        writesac(sacfile);
        k = k+1;
    end
end


%%  merge

indir = 'COR_Mianning_surface';
outdir = 'COR_Mianning_surface_merged';
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

figure('pos',[500 500 618 1000-618]);
hist(coef,50);
xlim([-1 1]);
xlabel('correlation coefficient');
ylabel('number of CCFs');

%% convert from sac CCF to yao's dat CCF format
indir = 'COR_Mianning_surface_merged';

filelist = dir([indir,'/*.SAC']);
nfile = length(filelist);

for i=1:nfile
    disp([i,nfile]);
    
    filepath = [filelist(i).folder,'/',filelist(i).name];
    sacfile = readsac(filepath);
    sig = sacfile.DATA1;
    b = sacfile.B;
    dt = sacfile.DELTA;
    n = sacfile.NPTS;
    t = b:dt:b+(n-1)*dt;
    
    stla = sacfile.STLA;
    stlo = sacfile.STLO;
    stel = sacfile.STEL; 
    evla = sacfile.EVLA;
    evlo = sacfile.EVLO;
    evel = sacfile.EVEL;
    if(isnan(stel)); stel=0; end
    if(isnan(evel)); evel=0; end
    
    nhalf = (n+1)/2;
    tp = t(nhalf:end)';
    sigp = sig(nhalf:end);
    sign = sig(nhalf:-1:1);
    AAA = [evlo evla evel;stlo stla stel;tp,sign,sigp];
    
    filepath = filepath(1:end-4);
    fid = fopen(filepath,'w');
    fprintf(fid,'%.6f %.6f %.6f\n',AAA');
    fclose(fid);
end



