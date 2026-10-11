function c_star = computeDimCStar_v2(NeuralData, Kfold, theta_error)
    % Compute dimensionality (c*: c_star) using K-fold cross-validation
    % The definition of c* follows:
    % Rigotti, Mattia, et al. "The importance of mixed selectivity in complex cognitive tasks." Nature 497.7451 (2013): 585-590, Supplementary Information (M.7).

    % INPUT:
    %       NeuralData: Neural activity, cell array:{s sessions × c conditions} (n neurons × t trials)
    %            Kfold: Number of folds for cross-validation
    %      theta_error: Threshold for the maximum allowed cross-validation error (e.g., 0.2 - 0.25)
    
    % v1: pooling all possible classification of all combination as total classifications.
    % v2: NO concatenation of NeuralData across single sessions
    % Xia Chen (2024)
    
    c = size(NeuralData,2); % {sessions, conditions}

    valid_classifiers_Array = zeros(1,c);
    valid_prob_Array =  ones(1,c);
    total_classifiers_Array = zeros(1,c); 
    % when i_cond == 1
    valid_classifiers_Array(1) = c;
    total_classifiers_Array(1) = c;
    
    for i_cond = 2:c
        % through all combinations of conditions
        total_combs = nchoosek(1:c, i_cond);
        total_classifiers_icomb = 2^i_cond; % total possible binary classification: 2^c
        total_classifiers_Array(i_cond) = size(total_combs,1)*total_classifiers_icomb;

        valid_classifiers = 0;

        elements = cell(1,i_cond);
        elements = cellfun(@(x) [-1 1], elements, 'UniformOutput', false);
        total_class = comb(elements);

        for i_comb = 1:size(total_combs,1) % for each combination

            for i_class = 1:size(total_class,1) % for each possible classification
                Data = NeuralData(:, total_combs(i_comb,:)); % {sess * condition}
                Label = total_class(i_class, :); % 1 * i_cond
                Label = Label';

                if numel(unique(Label))==1
                    MeanAcy = 1;
                else
                    Acy = nan(1,Kfold);
                    [TrainData, TestData] = get_Kfold_NeuralData(Data, Kfold); % conditions * units * kfold

                    for iFold = 1:Kfold % cross-validation
                        % train linear classifier
                        Mdl = fitcsvm(TrainData(:,:,iFold),Label,'ClassNames', [-1 1],'Standardize',true);
                        pred = predict(Mdl,TestData(:,:,iFold));
                        Acy(iFold) = sum(pred==Label)/i_cond;
                    end
                    MeanAcy = mean(Acy);
                end
                if MeanAcy > 1-theta_error
                    valid_classifiers = valid_classifiers + 1;
                end
            end
        end
        valid_classifiers_Array(i_cond) = valid_classifiers; % each entry is one of the combinations
        valid_prob_Array(i_cond) = valid_classifiers/total_classifiers_Array(i_cond);
    end
    c_star = find(valid_prob_Array>0.95);
    c_star = c_star(end);

end

