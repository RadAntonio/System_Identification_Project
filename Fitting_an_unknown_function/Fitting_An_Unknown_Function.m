%% INCEPUT DE PROGRAM
tic;
clear; clc;
%% INCARCAM SI CITIM DATELE
load("proj_fit_19.mat")
%Date Identificare
x1 = id.X{1};
x2 = id.X{2};
y = id.Y;

%Date Validare
valx1 = val.X{1};
valx2 = val.X{2};
valy = val.Y;

Yval = []; % Reshape matricea valy pentru a fi o singura linie
YhatFinal = []; % Matricia Yhat care este pentru degree ul cel mai optim
Y = []; % Acelasi lucru ca la Yval

MSE = []; % Vectorul MSE pentru Erori la Validare 
MSEid = []; % Vectorul MSE pentru Erori la Identificare

n=20; % Aici alegem Degree ul (mai mic de 100) XD
%% AFLAREA MATRICII PHI, YHAT, THETA, MSE

for k=1:n % for-ul care face cate o matrice PHI pentru fiecare degree
    Y = reshape(y, [], 1); % dam reshape la y intr un vector coloana sa il pot afla pe theta
    Yval = reshape(valy, [], 1); % dam reshape la valy ca sa putem afla yhat (avem nevoie de matricie linie)
    valreshape = ((k+1)*(k+2))/2; % un fel de suma lui Gauss, ca sa stim cum trebuie sa i dam reshape lui PHI in functie de degree
  
    PHIval = []; % declaram o matrice PHI de validare la fiecare iteratie a lui k
    PHI = []; % declaram o matrice PHI la fiecare iteratie a lui k

    % DATELE DE IDENTIFICARE

    for i=1:length(x1) %for-ul care creaza linile matricii PHI. selecteaza primul element din x1 care se inmulteste cu toate valorile din x2, etc. Contorul lui x1
        row = []; % cream un rand nou la fiecare linie noua
        for j=1:length(x2) % for-ul care creaza fiecare element de pe o linie. Contorul lui x2
            m = k; % m este gradul ca sa stim de unde coboara contorul
            while(m >= 0) % cat timp m este mai mare decat 0
            contor = 0; % avem un contor care ia 0 si va creste pana la m
                while(contor <= m) % cat timp contorul este mai mic decat m
                    row = [row; x1(i)^(contor)*x2(j)^(m-contor)]; % contruim fiecrae element astfel: a^0*b^m | a^1*b^m-1 | a^2*b^m-2 | etc... (in coloana) 
                    contor = contor + 1; % crestem contorul
                end
                m = m - 1; % scadem m-ul
            end
        end
        PHI = [PHI; row]; % concatenam fiecare rand in matricea PHI (va fi un vector coloana) 
    end

    PHI = reshape(PHI, valreshape, []); % dam reshape la matricea PHI in functie de ce degree aste folosind VALRESHAPE ce l am calculat mai sus
    PHI = PHI'; % transpunem matricea PHI ca sa o putem impartii cu matricea Y
    theta = PHI \ Y; % aflam THETA 
    Yhatid = PHI * theta; % aflam YHAT pentru datele de identificare
    N = length(x1); % N este lungimea vectorului x din datele de identificare

    for c=1:N   % facem suma de erori cu un for de la 1 la N
        mse = (Y(c)-Yhatid(c)).^2; % calculam MSE ul cu formula de Y - Yhat de Identificare
    end
    MSEid(k)=1/N * mse; % folosim formula finala pentru MSE care este suma inmultita cu 1/N

    if k == 1 
        Minid = MSEid(1); 
    
    elseif MSEid(k)<Minid
        Minid = MSEid(k);
        YhatIDFinal = Yhatid;
    end

    % DATELE DE VALIDARE
    % pentru datele de validare facem acelasi lucru ce am facut si pentru
    % datele de identificare :)
    for i=1:length(valx1)
        rowVal = [];
        for j=1:length(valx2)
            m = k;
            while(m >= 0)
            contor = 0;
                while(contor <= m)
                    rowVal = [rowVal; valx1(i)^(contor)*valx2(j)^(m-contor)];
                    contor = contor + 1;
                end
                m = m - 1;  
            end
        end
        PHIval = [PHIval; rowVal];
    end
    PHIval = reshape(PHIval, valreshape, []);
    PHIval = PHIval';
    yHat = PHIval * theta;

    N = length(valx1); % N este lungimea vectorului x din datele de validare
    for c=1:N
        mse = (Yval(c)-yHat(c)).^2;
    end

    MSE(k)=1/N * mse;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % alegem primul minim ca fiind MSE(1) iar dupa in else if verificam   %
    % daca gasim un MSE mai bun decat cel gasit anterior iar daca este mai%
    % bun, YhhatFinal o sa devina Yhat de degree-ul unde am gasit MSE-ul  %
    % cel mai mic                                                         %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if k == 1 
        Min = MSE(1); 
    
    elseif MSE(k)<Min
        Min = MSE(k);
        YhatFinal = yHat;
    end

end

%% GRAFICELE DE MSE-uri
% plotez grafu de erori
b = 1:n;
figure;
subplot(221)
plot(b, MSE);

title(["MSE graphic (from 1 to " num2str(n)]);
subplot(223)
plot(b, MSEid);

title(["MSEid graphic (from 1 to " num2str(n)]);

subplot(222)
plot(b, MSE);
hold on
axis([1 50 -5 40])
title(["Zoomed MSE graphic (from 1 to " num2str(n)]);
plot(4,Min,'r*')
hold off
subplot(224)
plot(b, MSEid);
axis([1 50 -5 40])
title(["Zoomed MSEid graphic (from 1 to " num2str(n)]);

%% GRAFICUL DATELOR DE IDENTIFICARE
%conditiile initiale (id X si Y )
figure;
surf(x1, x2, y);
title("Identification set");
%% GRAFICUL DATELOR DE VALIDARE
%conditiile de verificare (val X1 si X2 si Yhat)
YHAT = reshape(YhatFinal, 31, 31);
figure
surf(valx1,valx2,val.Y);
title("Validation set");
%% APROXIMAREA VALIDARE
figure
surf(valx1, valx2, YHAT);
title("Our aproximation for the validation set");
%% APROXIMAREA IDENTIFICARE
figure
YHATID = reshape(YhatIDFinal, 41, 41);
surf(x1, x2, YHATID);
title("Our aproximation for the identification set");
%% VALIDAREA SI APROXIMAREA PE ACELASI GRAFIC
YHAT = reshape(YhatFinal, 31, 31);
figure
surf(valx1,valx2,val.Y);
title("Afisare date validare");
hold on;
surf(valx1, valx2, YHAT);
title("The validation set and the aproximation on the same graph");

toc;