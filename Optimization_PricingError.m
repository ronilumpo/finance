%% Optimization Exercise (Project Work) Roni Lumpo K427692s

function res = Optimization_PricingError(data, settings, init_parameters)

    pSize = size(data.IVolSurf); %pSize(1) = n of maturities, pSize(2) = n of strikes
    kappa = init_parameters(1);
    theta = init_parameters(2);
    eta = init_parameters(3);
    rho = init_parameters(4);
    V0 = init_parameters(5);

    settingsOK = true;
    
    % Check if settings are ok or not
    if settings.standardError == false && ...
            (kappa < settings.minKappa || kappa > settings.maxKappa || ...
            theta < settings.minTheta || theta > settings.maxTheta || ...
            eta < settings.minEta || eta > settings.maxEta || ...
            rho < settings.minRho || rho > settings.maxRho || ...
            V0 < settings.minV0 || V0 > settings.maxV0)
        settingsOK = false;
    end

    if settingsOK
        
        parameters = {V0, theta, kappa, eta, rho};
        call_prices = zeros(pSize(1),pSize(2));
        model_IV = zeros(pSize(1),pSize(2));

        for i=1:pSize(1)
            % Calculate call-option prices with CallPricingFFT.m
            call_prices_tmp = CallPricingFFT(settings.model, settings.n, ...
                data.S0, data.K, data.T(i), data.r, 0, parameters{:});
            
            call_prices(i,:) = max(call_prices_tmp,0);
            
            % Convert obtained call prices to implied volatilities using blsimpv()
            model_IV(i,:) = blsimpv(data.S0, data.K, data.r, data.T(i), max(call_prices(i,:),0));
        end    

        % Calculate call-option pricing errors:  (marketIVs-modelIVs)^2
        errors = (data.IVolSurf - model_IV).^2;
        
        if settings.standardError == false
            % Take NANs into account!
            if sum(sum(isnan(errors))) > 0
                res = 1e10;
            else    
                res = sum(sum(errors));
            end  
        % If calculating standard errors, only modelIV vector needed    
        else    
            res = model_IV(:);
        end
        % Visualization
        if  settings.visualize == true && settings.standardError == false
            figure(1);
            surf(log(unique(data.K)), unique(data.T), model_IV);
            alpha(0.2)
            hold on;
            surf(log(unique(data.K)), unique(data.T), data.IVolSurf);
            hold off;
            xlabel('Log-Strike ($\log(K/S_0)$)','Interpreter','LaTex');
            ylabel('Maturity time ($T$, in years)','Interpreter','LaTex');
            zlabel('Implied volatility','Interpreter','LaTex');
            title('Data (non-transparent), model (transparent)','Interpreter','LaTex');
            drawnow;
        end
        
    % If settings are not OK, then punish the loss function
    else
       res = 1e10; 
    end   
end
