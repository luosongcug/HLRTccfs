function scal = wigbcc(a,scal,x,z,linecolor,fillcolor,amx)
%WIGB: Plot seismic data using wiggles.
%
%  WIGB(a,scal,x,z,amx)
%
%  IN  a:     seismic data (a matrix, traces are columns)
%      scale: multiple data by scal
%      x:     horizontal axis (often offset)
%      z:     vertical axis (often time)
%
%  Note
%
%    If only 'a' is enter, 'scal,x,z,amn,amx' are set automatically;
%    otherwise, 'scal' is a scalar; 'x, z' are vectors for annotation in
%    offset and time, amx are the amplitude range.
%
%
%  Author(s): Xingong Li (Intseis, Integrated Seismic Solutions)
%  Copyright 1998-2003 Xingong
%  Revision: 1.2  Date: Dec/2002
%  Copyright 2018 Yi Lin
%  Revision: 1.3  Date: April/2018
%  fix a bug: when a trace has its values being all negative and the same, and
% also very small, e.g. trace(:,17) = -1.39e-17, the original code fails. I fixed
% this bug by simply modify the line 75.

% Song Luo, 2021/05/21, revised wigb.m to plot cross-correlation functions,
% in addition, I fixed an bug and excluded the white line existed in black areas.
% Song Luo, 2021/07/03, revised a bug by letting tr(1)<0 to tr(1)<=0 and
% tr(nz)<0 to tr(nz)<=0.
% Song Luo, 2021/08/10, fix a bug by letting tr(1)<=0 and tr(nz)<=0 to
% tr(nz)>0 and tr(nz)>0

if nargin == 0, nx=10;nz=10; a = rand(nz,nx)-0.5; end

[nz,nx]=size(a);

% Song Luo added, 2021/6/23, add the following codes to avoid too large
% trace number
if nx > 100
    index = round(linspace(1,nx,100));
    nx = length(index);
    a = a(:,index);
    if (nargin >2 ); x = x(index); end
end

trmx= max(abs(a));
if (nargin <= 5); fillcolor = [0 0 0]; end
if (nargin <= 4); linecolor = [0 0 0]; end
if (nargin <= 6); amx=mean(trmx);  end
if (nargin <= 2); x=[1:nx]; z=[1:nz];  end
if (nargin <= 1); scal =1; end

if nx < 1; disp(' ERR:PlotWig: nx has to be more than 1');return;end


% take the average as dx

dx1 = abs(x(2:nx)-x(1:nx-1));
dx = median(dx1);

if nx==1
    dx = x(1)/100;
end

dz=z(2)-z(1);
xmx=max(max(a)); xmn=min(min(a));

if scal == 0; scal=1; end
if amx==0
    a = a*scal;
else
    a = a * dx /amx;
    a = a * scal;
    scal = scal*dx/amx;
end

fprintf(' PlotWig: data range [%f, %f], plotted max %f \n',xmn,xmx,amx);

% set display range

x1=min(x)-2.0*dx; x2=max(x)+2.0*dx;
z1=min(z)-dz; z2=max(z)+dz;

 set(gca,'NextPlot','add','Box','on', ...
  'YLim', [x1 x2], ...
  'YDir','normal', ...
  'XLim',[z1 z2]);


% fillcolor = [0 0 0];
% linecolor = [0 0 0];
% linewidth = 1.;
linewidth = 0.5;

z=z'; 	% input as row vector
zstart=z(1);
zend  =z(nz);

for i=1:nx
    
    if trmx(i) ~= 0 && trmx(i) >= 1e-8    % skip the zero traces, fix the bug
        tr=a(:,i); 	% --- one scale for all section
        s = sign(tr) ;
        i1= find( s(1:nz-1) ~= s(2:nz) );	% zero crossing points
        npos = length(i1);
        
        
        %12/7/97
        zadd = i1 + tr(i1) ./ (tr(i1) - tr(i1+1)); %locations with 0 amplitudes
        aadd = zeros(size(zadd));
        
        [zpos,~] = find(tr >0);
        [zz,iz] = sort([zpos; zadd]); 	% indices of zero point plus positives
        aa = [tr(zpos); aadd];
        aa = aa(iz);
        
        % be careful at the ends
        if tr(1)>0, 	a0=0; z0=1.00;
        else, 		a0=0; z0=zadd(1);
        end
        if tr(nz)>0, 	a1=0; z1=nz;
        else, 		a1=0; z1=max(zadd);
        end
        
        zz = [z0; zz; z1; z0];
        aa = [a0; aa; a1; a0];
        
        zzz = zstart + zz*dz -dz;
        
        
        patch( zzz , aa+x(i),  fillcolor,'EdgeColor','none');
        
        line( 'Color',linecolor,  ...
            'LineWidth',linewidth, ...
            'Ydata', tr+x(i), 'Xdata',z);	% negatives line
        
    else % zeros trace
        
%         line( 'Color',linecolor,  ...
%             'LineWidth',linewidth, ...
%             'Ydata', [x(i) x(i)], 'Xdata',[zstart zend]);
        
    end
end

