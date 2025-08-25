function [rich_club_coeff, rich_club_coeff_rand] = rich_club_analysis_normalized(A,Nrand)
    % Ensure the matrix is binary and symmetric
    A = A > 0;
    %A = A | A';

    % Get the degree of each node
    degrees = sum(A, 2);

    % Determine the maximum degree
    max_degree = max(degrees);

    % % Number of randomizations
    num_randomizations = 50;

    % Initialize the rich-club coefficient array
    rich_club_coeff_rand = zeros(Nrand, max_degree);

    [rich_club_coeff,~,~] = rich_club_calc(A,max_degree);
f = waitbar(0, 'Starting');
    for i = 1:Nrand
        %A_rand = randmio_und_connected(A, num_randomizations);
        A_rand = randmio_und(A, num_randomizations);
        
        [rich_club_coeff_rand(i,:),~,~] = rich_club_calc(A_rand,max_degree);
waitbar(i / Nrand, f, ['Finished network ', num2str(i), '/', num2str(Nrand)]);
    end
close(f)

end

function [R,Nk,Ek] = rich_club_calc(CIJ,varargin)
%RICH_CLUB_BU        Rich club coefficients (binary undirected graph)
%
%   R = rich_club_bu(CIJ)
%   [R,Nk,Ek] = rich_club_bu(CIJ,klevel)
%
%   The rich club coefficient, R, at level k is the fraction of edges that
%   connect nodes of degree k or higher out of the maximum number of edges
%   that such nodes might share.
%
%   Input:      CIJ,        connection matrix, binary and undirected
%            klevel,        optional input argument. klevel sets the
%                              maximum level at which the rich club
%                              coefficient will be calculated. If klevel is
%                              not included the the maximum level will be
%                              set to the maximum degree of CIJ.
%
%   Output:       R,        vector of rich-club coefficients for levels
%                              1 to klevel.
%                Nk,        number of nodes with degree>k
%                Ek,        number of edges remaining in subgraph with
%                              degree>k
%
%   Reference: Colizza et al. (2006) Nat. Phys. 2:110.
%
%   Martijn van den Heuvel, University Medical Center Utrecht, 2011

Degree = sum(CIJ);  %compute degree of each node

if nargin == 1
    klevel = max(Degree);
elseif nargin == 2
    klevel = varargin{1};
elseif nargin > 2
    error('number of inputs incorrect. Should be [CIJ], or [CIJ, klevel]')
end

R = zeros(1,klevel);
Nk = zeros(1,klevel);
Ek = zeros(1,klevel);
for k = 1:klevel
    SmallNodes=find(Degree<=k);       %get 'small nodes' with degree <=k
    subCIJ=CIJ;                       %extract subnetwork of nodes >k by removing nodes <=k of CIJ
    subCIJ(SmallNodes,:)=[];          %remove rows
    subCIJ(:,SmallNodes)=[];          %remove columns
    Nk(k)=size(subCIJ,2);             %number of nodes with degree >k
    Ek(k)=sum(subCIJ(:));             %total number of connections in subgraph
    R(k)=Ek(k)/(Nk(k)*(Nk(k)-1));     %unweighted rich-club coefficient
end

end