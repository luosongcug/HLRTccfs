function seisr = modsep_auto(f,p,t,dist,seis,flim,plim)

% flim = [f1 f2], frequency range to filter (Hz)
% plim = [p1 p2], slowness range to filter (s/km)

stackexnum = 5;
stackinnum = 5;

fmn = f(1); fmx = f(end); df = f(2)-f(1); nf = length(f);
pmn = p(1); pmx = p(end); dp = p(2)-p(1); np = length(p);
tmn = t(1); tmx = t(end); dt = t(2)-t(1); nt = length(t);


% sort the seismograms
[dist,loc] = sort(dist);
seis = seis(:,loc);

% Fourier transform
nt = size(seis,1);
fseis = fft(seis,nt);

dff = 1/(nt*dt);
fn = round(f/dff)+1;
om = 2*pi*f;
ntrace = size(fseis,2);

LL = NaN(ntrace,np);
for i=1:ntrace
    for j=1:np
        LL(i,j) = 1i*p(j)*dist(i);
    end
end

dispen = NaN(np,nf);
% for i=1:nf
parfor(i=1:nf,10)
    disp([i nf]);
%     Wm = diag(ones(1,np));
%     Wd = diag(ones(1,ntrace));
    
%    for stack=1:stackexnum
        
        LLf = exp(LL*om(i));
        d = fseis(fn(i),:)';
        
%        Lw = Wd*LLf;
%        dw = Wd*d;
        
%        dispen(:,i) = lsqr(Lw,dw,1e-7,stackinnum,Wm,Wm);
        dispen(:,i) = lsqr_precondition(LLf,d,stackexnum,stackinnum,1e-7);
        
%        if stack>1
            
%            d = fseis(fn(i),:)';
%            m = dispen(:,i);
            
%            mstd = std(m);
%            Wm = diag(1./sqrt(mstd+m));
            
%            dres = LLf*m-d;
%            dstd = std(dres);
%            Wd = diag(1./sqrt(dstd+abs(dres)));
            
%        end
%     end
end

%% mode separation
p1 = plim(1); p2 = plim(2);
f1 = flim(1); f2 = flim(2);

nf1 = (f1-fmn)/df; nf2 = (f2-fmn)/df;
np1 = (p1-pmn)/dp; np2 = (p2-pmn)/dp;
np3 = (-p1-pmn)/dp; np4 = (-p2-pmn)/dp;


bw1 = poly2mask([nf1 nf2 nf2 nf1 nf1],[np1 np1 np2 np2 np1],np,nf);
bw2 = poly2mask([nf1 nf2 nf2 nf1 nf1],[np3 np3 np4 np4 np3],np,nf);
bw = bw1|bw2;

% mute values outside the selected mode region
dispen_mute = dispen;
dispen_mute(~bw) = 0+1i*0;


%% dispen to seis
LLr = NaN(np,ntrace);
for i=1:ntrace
    for j=1:np
        LLr(j,i) = -1i*p(j)*dist(i);
    end
end

seisr = NaN(ntrace,nf);
for i=1:nf
    disp([i,nf]);
    LLrf = exp(LLr*om(i));
    seisr(:,i) = LLrf'*dispen_mute(:,i);
end

seisr = seisr';
seisr = ifft(seisr,nt,'symmetric');
seisr = real(seisr);




function m = lsqr_precondition(LLf,d,stackexnum,stackinnum,tol)

[nd,nv] = size(LLf);

Wm = diag(ones(1,nv));
Wd = diag(ones(1,nd));

for stack=1:stackexnum
    Lw = Wd*LLf;
    dw = Wd*d;
    
    [m,flag,relres,iter,resvec,lsvec] = lsqr(Lw,dw,tol,stackinnum,Wm,Wm);
    % lsvec = (lsvec(1:iter)./(nd-(1:iter)')).^2;
    resvec = (resvec(1:iter)./(nd-(1:iter)')).^2;
    [~,itermx] = min(resvec);
    [m,flag,relres,iter,resvec,lsvec] = lsqr(Lw,dw,1e-7,itermx,Wm,Wm);
    
    ma = abs(m);
    ma(ma<=1e-6) = 1e-6;
    mstd = std(m);
    Wm = diag(1./sqrt(mstd+ma));
end