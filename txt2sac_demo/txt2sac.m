% This program is to convert CCFs in ascii format into sac format.
% initial code by Song Luo, 2018/5/16
% Song Luo, 2023/8/22, release codes

clear;

indir = 'ascii';
outdir = 'sac';
if ~exist(outdir,'dir')
    mkdir(outdir)
end

filelist = dir([indir,'/ZZ*.dat']);

for i=1:length(filelist)
    i
    AAA = load([filelist(i).folder,'/',filelist(i).name]);
    lons = AAA(1,1); lats = AAA(1,2);
    lonr = AAA(2,1); latr = AAA(2,2);
    t = AAA(3:end,1); ncfl = AAA(3:end,2); ncfr = AAA(3:end,3);
    t = [-flipud(t);t(2:end)]; ncf = [flipud(ncfl);ncfr(2:end)];
    sacfile = readsac('sachd.sac');
    sacfile.FILENAME = [outdir,'/',filelist(i).name,'.SAC'];
    sacfile.NPTS = length(ncf);
    sacfile.DELTA = t(2)-t(1);
    sacfile.B = t(1);
    sacfile.STLA = latr; sacfile.STLO = lonr;
    sacfile.EVLA = lats; sacfile.EVLO = lons;
    sacfile.OMARKER = 0;
    sacfile.NZYEAR = 2019; sacfile.NZJDAY = 1;
    sacfile.NZHOUR = 0; sacfile.NZMIN = 0; sacfile.NZSEC = 0; sacfile.NZMSEC = 0;
    sacfile.KSTNM = 'COR';
    sacfile.KCMPNM = 'ZZ';
    sacfile.DATA1 = ncf;
    sacfile.LCALDA = true;
    writesac(sacfile);
end

