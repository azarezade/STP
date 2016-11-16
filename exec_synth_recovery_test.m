folder_name=strcat('Results/Synth/spatial_etk_synth');
N=50;
dataset_length=8;
roc=zeros(N,dataset_length);
roc_unoverfit=zeros(N,dataset_length);

    for i=1:1:N
        for j=1:1:dataset_length
            data_name_title=strcat('parameters_user_',num2str(i),'_trainset_',num2str(j));
            
            file_name=fullfile(pwd,folder_name,data_name_title);
            load(file_name);
            currentvar_spatial=currentvar_spatial(1:N);
            currentvar_spatial_unoverfit=currentvar_spatial_unoverfit(1:N);
            
            org_binary=org_params_spatial(1:N)>0;
            org_binary=full(org_binary);
            number_of_positives=length(find(org_binary)==1);
            currentvar_spatial_exp=exp(currentvar_spatial);
            %currentvar_spatial_exp=currentvar_spatial_exp./max(currentvar_spatial_exp);
                
            currentvar_spatial_exp_unoverfit=exp(currentvar_spatial_unoverfit);
            %currentvar_spatial_exp_unoverfit=currentvar_spatial_exp_unoverfit./max(currentvar_spatial_exp_unoverfit);
                
            %current_binary=currentvar_spatial_exp>=threshold(thre);
            %current_unoverfit_binary=currentvar_spatial_exp_unoverfit>=threshold(thre);
        
            [~,~,~,roc(i,j)]=perfcurve(org_binary,currentvar_spatial_exp,logical(1));
            [~,~,~,roc_unoverfit(i,j)]=perfcurve(org_binary,currentvar_spatial_exp_unoverfit,logical(1));
        end
    end

roc_final=sum(roc);
roc_final=roc_final./N;
roc_final_unoverfit=sum(roc_unoverfit);
roc_final_unoverfit=roc_final_unoverfit./N;
%plot(roc_final);
%hold on
%plot(roc_final_unoverfit);
