function [r, J] = localcalculateresiduals(PTAM, range, counts, map,calcJ,ids)
%CALCULATERESIDUALS Summary of this function goes here
%   Detailed explanation goes here

% ncameras = size(KeyFrames,2);
% npoints = size(Map.points,2);




nresi = 2*round(sum(counts));
npoints = size(ids,1);
nparam = 3*npoints + 6*size(range,2);


r = zeros(nresi,1);
J = zeros(nresi,nparam);

K = PTAM.Camera.K;
row = -1;
pointparams = 3;
camparams = 6;





for i = 1:npoints
    for j = 1:size(PTAM.KeyFrames,2)
         
        E = PTAM.KeyFrames(j).Camera.E;
        pointIndex = map{j}(ids(i));
        imagePoint = [];
        if pointIndex > 0
            imagePoint = PTAM.KeyFrames(j).ImagePoints(pointIndex).location;
        end
        
        
        
        if ~isempty(imagePoint)  
            row = row + 2;
            
            
            
            
            
            mapPoint = PTAM.Map.points(ids(i));
            
            pointCamera = E*mapPoint.location;
            X = pointCamera(1);
            Y = pointCamera(2);
            Z = pointCamera(3);
            x = X/Z;
            y = Y/Z;
            
            
            imagePoint = K\imagePoint;
            
            u = imagePoint(1);
            v = imagePoint(2);
            
            r(row) = (x-u);
            r(row + 1) = (y-v);
            
            for p = 1:pointparams
                [dX_dp dY_dp dZ_dp] = diffXn3D(E,p);
                J(row,p + 3*(i-1)) = (dX_dp*Z - dZ_dp*X)/(Z^2);
                J(row + 1,p + 3*(i-1)) = (dY_dp*Z - dZ_dp*Y)/(Z^2);
            end
            
            if sum(j==range)>0
                kfcount = find(range==j);
                for c = 1:camparams
                    [dX_dp dY_dp dZ_dp] = expdiffXn(X,Y,Z,eye(4,4),c);
                    J(row,3*npoints + c + 6*(kfcount-1)) = (dX_dp*Z - dZ_dp*X)/(Z^2);
                    J(row + 1,3*npoints + c + 6*(kfcount-1)) = (dY_dp*Z - dZ_dp*Y)/(Z^2);
                end
            end
            
            
            
        end
    end
end










% for i = 1:size(ids,1);
%
%
%
%
%
% end
%
%
%
%
%
% row = -1;
% for i = 1:ncameras
%     E = KeyFrames(i).Camera.E;
%
%     for j = 1:npoints
%         row = row + 2;
%         id = Map.points(j).id;
%         pointIndex = map{i}(id);
%         imagePoint = [];
%         if pointIndex > 0
%             imagePoint = KeyFrames(i).ImagePoints(pointIndex).location;
%         end
%
%
%
%         if ~isempty(imagePoint)
%             pointCamera = E*Map.points(j).location;
%             X = pointCamera(1);
%             Y = pointCamera(2);
%             Z = pointCamera(3);
%             x = X/Z;
%             y = Y/Z;
%
%
%             imagePoint = K\imagePoint;
%
%             u = imagePoint(1);
%             v = imagePoint(2);
%
%             r(row) = (x-u);
%             r(row + 1) = (y-v);
%
%             if calcJ
%                 for p = 1:pointparams
%                     [dX_dp dY_dp dZ_dp] = diffXn3D(E,p);
%                     J(row,p + 3*(j-1)) = (dX_dp*Z - dZ_dp*X)/(Z^2);
%                     J(row + 1,p + 3*(j-1)) = (dY_dp*Z - dZ_dp*Y)/(Z^2);
%                 end
%
%                 if i > 1
%                     for c = 1:camparams
%                         [dX_dp dY_dp dZ_dp] = expdiffXn(X,Y,Z,eye(4,4),c);
%                         J(row,3*npoints + c + 6*(i-2)) = (dX_dp*Z - dZ_dp*X)/(Z^2);
%                         J(row + 1,3*npoints + c + 6*(i-2)) = (dY_dp*Z - dZ_dp*Y)/(Z^2);
%                     end
%                 end
%             end
%
%
%         end
%     end
% end
%
%
% end



