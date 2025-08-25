function Athr = strength_threshold(A,Edges2select)

N = length(A);

if Edges2select<1
prop =Edges2select;
TotalEdges = (N^2-N)/2;
Edges2select = round(prop*TotalEdges);
end

Avec = triu2vec(A);

Avec_sorted = sort(Avec,'descend');

thr = Avec_sorted(Edges2select);

Athr = A.*(A>=thr); 