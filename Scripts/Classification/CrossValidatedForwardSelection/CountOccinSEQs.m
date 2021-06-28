function [COUNTOCC, AccOcc]=CountOccinSEQs(SEQ, AccDist)
COUNTOCC=zeros(18,1);
AccOcc=zeros(18,1);
for i=1:size(SEQ,1)
    for f=1:size(SEQ,2)
        if ismember(f, SEQ(i,:))
            COUNTOCC(f)=COUNTOCC(f)+1;
            AccOcc(f)=AccOcc(f)+AccDist(i);
        end
    end
end
end
