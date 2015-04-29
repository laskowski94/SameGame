program Samegame;
{Krzysztof Laskowski}
{Samegame to komputerowa gra logiczna, w ktorej nalezy usunac jak najwieksza liczbe 'blokow' wypelnionych odpowiednimi znakami}
const max_kolumny = 'z';						//maksymalna liczba kolumny w planszy
  max_wiersze = 20;							//maksymalna liczba wierszy w planszy
  
type tablica = array[chr(ord('a')-1)..chr(ord(max_kolumny)+1),0..max_wiersze+1] of Char;//2-wymiarowa tablica, ktora jest szersza i wyzsza o 1 ze wzgledu na straznikow 
  
var Plansza : tablica;							//plansza do gry
  grawitacja_kolumn : array['a'..max_kolumny] of Byte;			//tablica, w ktorej jest zapisane czy dana kolumna wymaga grawitacji
  znaki_gracz1,znaki_gracz2 : String;					//zapisane dozwolone znaki gracza 1 i gracza 2
  kto_zaczyna,liczba_wierszy : Byte;					//maksymalna liczba wierszy w planszy
  max_blok : Longint;							//maksymalny blok mozliwy do usuniecia przez komputer
  znak_kolumny : Char;							//maksymalna liczba kolumn w planszy

procedure generujLiczbePseudolosowa(var x : Longint);			//kod generujacy liczby pseudolosowe
const
    M = MAXLONGINT;
    A = 7 * 7 * 7 * 7 * 7;
    Q = M div A;
    R = M mod A;
begin
    assert(M = 2147483647);
    assert(A = 16807);
    assert(R < Q);
    x := A * (x mod Q) - R * (x div Q);
    if x < 0 then
        x := x + M
end;

procedure wczytaj_dane;							//procedura wczytujaca dane poczatkowe, rozmiar tablicy, liczbe do generowania liczb
var A : array['!'..'~'] of Byte;					//pseudolosowych, numer 1 gracza oraz znaki dozwolone dla graczy. Nastenie wypisuje plansze.
  i : Char;								//w tablicy A zapisuje dozwolone znaki dla danego gracza, w celu skrocenia Stringa do 
  liczba_kolumn,j : Byte;						//postaci, w ktorej nie powtarzaja sie znaki
  Napis1,Napis2,Napis1_2 : String;
  x : Longint;
procedure wypelnij_plansze;						//wewnetrzna procedura wypelniajaca plansze
var i : Byte;
    j : Char;
begin
  for i:=0 to max_wiersze+1 do Plansza[chr(ord('a')-1),i]:=chr(169);	//wstawianie straznikow wokol planszy
  for i:=0 to max_wiersze+1 do Plansza[chr(ord(max_kolumny)+1),i]:=chr(169);
  for j:=chr(ord('a')-1) to chr(ord(max_kolumny)+1) do Plansza[j,0]:=chr(169);
  for j:=chr(ord('a')-1) to chr(ord(max_kolumny)+1) do Plansza[j,max_wiersze+1]:=chr(169);
  for j:='a' to znak_kolumny do
    for i:=1 to liczba_wierszy do
    begin
      generujLiczbePseudolosowa(x);
      Plansza[j,i]:=Napis1_2[1 + x mod length(Napis1_2)]		//wypelnienie planszy wygenerowanymi znakami
    end;
end;

begin
  for i:='!' to '~' do A[i]:=0;						//wyzerowanie tablicy
  read(liczba_kolumn);
  znak_kolumny:=chr(liczba_kolumn + 96);				//zamiana liczby kolumn na odpowiednia litere alfabetu
  read(liczba_wierszy);
  read(x);								//wczytanie zmiennej do generowania liczb pseudolosowych
  readln(kto_zaczyna);
  readln(Napis1);							//wczytanie znakow dla gracza1
  znaki_gracz1:=Napis1;
  readln(Napis2);							//wczytanie znakow dla gracza2
  znaki_gracz2:=Napis2;
  for j:=1 to length(Napis1) do if A[Napis1[j]]=0 then A[Napis1[j]]:=1;	//zaznaczenie w tablicy dozwolonych znakow dla gracza1
  j:=1;
  for i:='!' to '~' do if A[i]=1 then
  begin
    znaki_gracz1[j]:=i;							//tworzymy Stringa, w ktorym kazdy znak wystepuje tylko raz
    inc(j);
  end;
  delete(znaki_gracz1,j,length(znaki_gracz1)-j+1);			//usuwamy reszte znakow ze Stringa
  for i:='!' to '~' do A[i]:=0;						//wyzerowanie tablicy
  for j:=1 to length(Napis2) do if A[Napis2[j]]=0 then A[Napis2[j]]:=1;	//to samo co wczesniej tylko, ze dla znakow gracza2
  j:=1;
  for i:='!' to '~' do if A[i]=1 then
  begin
    znaki_gracz2[j]:=i;
    inc(j);
  end;
  delete(znaki_gracz2,j,length(znaki_gracz2)-j+1);
  Napis1_2:=Napis1+Napis2;
  wypelnij_plansze;
end;

procedure wypisz_plansze;						//procedura wypisujaca plansze
var i : Byte;
  j : Char;
begin
  write('  +');
  for j:='a' to znak_kolumny do write('--');
  writeln('-+');
  for i:=liczba_wierszy downto 1 do
  begin
    write(i mod 10,' |');
    for j:='a' to znak_kolumny do write(' ',Plansza[j,i]);
    writeln(' |');
  end;
  write('  +');
  for j:='a' to znak_kolumny do write('--');
  writeln('-+');
  write('   ');
  for j:='a' to znak_kolumny do write(' ',j);
  writeln();
end;

procedure usun_blok(i : Char; j : Byte; znak : Char);			//procedura, ktora usuwa z planszy caly blok danego znaku, zlicza jego wielkosc oraz
var k : Char;								//zapisuje w tablicy grawitacja_kolumn, z ktorych kolumn zostal usuniety znak
  
procedure usun(i : Char; j : Byte; znak : Char);			//wewnetrzna procedura usuwajaca blok znakow
begin
  if Plansza[i,j]=znak then
  begin
    Plansza[i,j]:=' ';							//usuniecie znaku
    inc(max_blok);							//zliczanie wielkosci bloku
    if grawitacja_kolumn[i]=0 then grawitacja_kolumn[i]:=1;		//zaznaczenie tego, ze w danej kolumnie zostal usuniety znak
    if i>'a' then usun(chr(ord(i)-1),j,znak);				//kolejne wywolania rekurencyjne dla procedury usun w 4 kierunkach
    if (i<znak_kolumny) then usun(chr(ord(i)+1),j,znak);
    if (j>1) then usun(i,j-1,znak);
    if (j<liczba_wierszy) then usun(i,j+1,znak);
  end;
end;

begin
  for k:='a' to znak_kolumny do grawitacja_kolumn[k]:=0;		//wyzerowani tablicy
  max_blok:=0;
  usun(i,j,znak);							//usuniecie bloku znakow
end;

procedure grawitacja_pionowa(a : Char);					//procedure, ktora wykonuje grawitacje pionowa dla konkretnej kolumny
var i,j : Byte;
begin
  i:=1;
  j:=1;
  while (j<=liczba_wierszy) and (Plansza[a,i]<>' ') do			//szukamy od dolu pierwszego wolnego miejsca w danej kolumnie
  begin
    inc(i);
    inc(j);
  end;
  while (j<=liczba_wierszy) do						//dopoki nie dojdziemy do samej gory planszy
  begin
    while (j<=liczba_wierszy) and (Plansza[a,j]=' ') do inc(j);		//i ustawione na pierwszym wolnym mijescu, wskaznikiem j szukamy pierwszego zajetego miejsc
    if (j<=liczba_wierszy) then
    begin
      Plansza[a,i]:=Plansza[a,j];					//zamieniamy wartosc z wysokosci i z wartoscia z wysokosci j
      Plansza[a,j]:=' ';						//wartosc na wysokosci j staje sie pusta
      inc(i);								//zwiekszamy wartosc i
    end;
  end;
end;  
      
procedure grawitacja_pozioma;						//procedura wykonujaca grawitacje pozioma
var i1,j1 : Char;
  i2 : Byte;
begin
  i1:='a';
  j1:='a';
  i2:=1;
  while (j1<=znak_kolumny) and (Plansza[i1,i2]<>' ') do			//szukamy pierwszej wolnej kolumny od lewej strony
  begin
    inc(i1);
    inc(j1);
  end;
  while (j1<=znak_kolumny) do
  begin
    while (j1<=znak_kolumny) and (Plansza[j1,i2]=' ') do inc(j1);	//i1 ustawione na pierwszej wolnej kolumnie i szukamy pierwszej zajetej kolumny za pomoca j1
    if (j1<=znak_kolumny) then 
    begin
      while (i2<=liczba_wierszy) and (Plansza[j1,i2]<>' ') do		//do samej gory
      begin
	Plansza[i1,i2]:=Plansza[j1,i2];					//kopiujemy kolumne z j1 do kolumny i1 i usuwamy kolumne j2
	Plansza[j1,i2]:=' ';
	inc(i2);				
      end;
      i2:=1;
      inc(i1);
    end;
  end;
end;  

procedure start;							//procedura rozpoczynajaca prace programu, wczytuje dane, inicjalizuje max_blok
begin									// oraz wypisuje plansze
  wczytaj_dane;
  max_blok:=2;
  wypisz_plansze;
end;

procedure gra;								//procedura grajaca
var dalej : Boolean;
  wsp_od_gracza_kolumna,wsp_kolumn_najlepszy_blok : Char;
  punktacja : Longint;
  poprawne : boolean;
  wsp_od_gracza_wiersz,wsp_wierszy_najlepszy_blok : Byte;

procedure inteligencja(A : tablica; lista_znakow : String);		//procedura, ktora znajduje najwiekszy blok, podaje jego 'pierwsza' wspolrzedna,
var znak,i,min_i,wsp_i_bloku : Char;					//podaje jego wielkosc
  k,j,min_j,wsp_j_bloku : Byte;
  jest : Boolean;
  ile : Longint;

procedure usun_komp(i : Char; j : Byte; znak : Char);			//wewnetrzna procedura usuwajaca, znaki z kopii planszy i znajdujaca minimalna wspolrzedna
begin
  if A[i,j]=znak then
  begin
    if i<wsp_i_bloku then						//jesli element z danego bloku jest dotychaczas najbardziej po prawej stronie
    begin								//to zapamietujemy jego wspolrzedne
      wsp_i_bloku:=i;
      wsp_j_bloku:=j;
    end
    else if i=wsp_i_bloku then if j<wsp_j_bloku then wsp_j_bloku:=j;	//jesli jest w tej samej kolumnie, ale nizej, to rowniez zapamietujemy jego wspolrzedna
    inc(ile);								//zliczamy elementy bloku
    A[i,j]:=' ';							//czyscimy znak w kopii planszy
    if i>'a' then usun_komp(chr(ord(i)-1),j,znak);			//przechodzimy rekurencyjnie w 4 kierunkach w miejsca gdzie jest taki sam znak
    if (i<znak_kolumny) then usun_komp(chr(ord(i)+1),j,znak);
    if (j>1) then usun_komp(i,j-1,znak);
    if (j<liczba_wierszy) then usun_komp(i,j+1,znak);
  end;
end;

begin
  max_blok:=0;
  for i:='a' to znak_kolumny do						//przeszukujemy cala kopie planszy
    for j:=1 to liczba_wierszy do
    begin
      jest:=false;
      k:=1;
      while (not jest) and (k<=length(lista_znakow)) do			//szukamy znak z przeszukiwanego miejsca w planszy jest dozwolonym znakiem
	if lista_znakow[k]=A[i,j] then
	begin
	  jest:=true;
	  znak:=lista_znakow[k];
	end
	else inc(k);
      if not jest then A[i,j]:=' '					//czyscimy sprawdzadzone miejsce
      else begin
	ile:=0;
	wsp_i_bloku:=znak_kolumny;					//inicjalizujemy wspolrzedne bloku na maksymalne
	wsp_j_bloku:=liczba_wierszy;
	usun_komp(i,j,znak);						//sprawdzamy wielkosc bloku i usuwamy go z kopii planszy
	if ile>max_blok then						//jesli znalezlismy wiekszy blok to zapamietujemy jego wielkosc oraz wspolrzedne
	begin
	  max_blok:=ile;
	  min_i:=wsp_i_bloku;
	  min_j:=wsp_j_bloku;
	end
	else if ile=max_blok then					//jesli trafilismy na blok o takiej samej wielkosci jak maks to sprawdzamy
	begin								//czy wspolrzedne nie sa korzystniejsze
	  if wsp_i_bloku<min_i then
	  begin
	    min_i:=wsp_i_bloku;
	    min_j:=wsp_j_bloku;
	  end
	  else if wsp_i_bloku=min_i then if wsp_j_bloku<min_j then min_j:=wsp_j_bloku;
	end;
      end;
    end;
  wsp_kolumn_najlepszy_blok:=min_i;					//zapisujemy wsporzedne na zmiennych globalnych
  wsp_wierszy_najlepszy_blok:=min_j;
end;
  
procedure dane_od_gracza(lista_znakow : String);		//procedura wczytujaca dane od graczy i informujaca o tym, czy zostalo podane prawidlowe polecenie
var napis : String;
  i,k : Byte;
  jest : Boolean;
begin
  if not eof then
  begin
    repeat
      readln(napis);
      if length(napis)=2 then					//wczytaine 2 wspolrzednych
      begin
	wsp_od_gracza_kolumna:=napis[1];
	wsp_od_gracza_wiersz:=(ord(napis[2])-49)+1;
      end
      else begin
	wsp_od_gracza_kolumna:=napis[1];
	i:=(ord(napis[2])-49)+1;
	wsp_od_gracza_wiersz:=((10*i)+((ord(napis[3])-49)+1));
      end;
      jest:=false;
      k:=1;
      while (not jest) and (k<=length(lista_znakow)) do		//sprawdzenie czy podane wspolrzedne sa odpowiednie do listy znakow gracza
	if lista_znakow[k]=Plansza[wsp_od_gracza_kolumna,wsp_od_gracza_wiersz] then
	begin
	  jest:=true;
	end
	else inc(k);
  {wspolrzedna jest poprawna, gdy znak nalezy do listy znakow gracza oraz blok jest minimum 2-elementowy}
    until ((jest) and ((Plansza[wsp_od_gracza_kolumna,wsp_od_gracza_wiersz]=Plansza[wsp_od_gracza_kolumna,wsp_od_gracza_wiersz-1]) or
		     (Plansza[wsp_od_gracza_kolumna,wsp_od_gracza_wiersz]=Plansza[wsp_od_gracza_kolumna,wsp_od_gracza_wiersz+1]) or
		     (Plansza[wsp_od_gracza_kolumna,wsp_od_gracza_wiersz]=Plansza[chr(ord(wsp_od_gracza_kolumna)-1),wsp_od_gracza_wiersz])   or
		     (Plansza[wsp_od_gracza_kolumna,wsp_od_gracza_wiersz]=Plansza[chr(ord(wsp_od_gracza_kolumna)+1),wsp_od_gracza_wiersz]))) or (eof);
  end;
  {jesli eof to sprawdzamy czy ostatnia podana wspolrzedna jest poprawna}
  if (eof) and (not ((Plansza[wsp_od_gracza_kolumna,wsp_od_gracza_wiersz]=Plansza[wsp_od_gracza_kolumna,wsp_od_gracza_wiersz-1]) or
		     (Plansza[wsp_od_gracza_kolumna,wsp_od_gracza_wiersz]=Plansza[wsp_od_gracza_kolumna,wsp_od_gracza_wiersz+1]) or
		     (Plansza[wsp_od_gracza_kolumna,wsp_od_gracza_wiersz]=Plansza[chr(ord(wsp_od_gracza_kolumna)-1),wsp_od_gracza_wiersz])   or
		     (Plansza[wsp_od_gracza_kolumna,wsp_od_gracza_wiersz]=Plansza[chr(ord(wsp_od_gracza_kolumna)+1),wsp_od_gracza_wiersz])))
		     then jest:=false;
  poprawne:=jest;
end;

procedure ruch_gracza(znaki : String);				//procedura wykonujaca ruch gracza
var i : Char;
begin
  dane_od_gracza(znaki);					//pobiera dane od gracza
  if poprawne then						//jesli sa poprawne to: usuwa blok, zmienia punktacje, wykonuje grawitacje, wypisuje wyink oraz
  begin								//plansze
    usun_blok(wsp_od_gracza_kolumna,wsp_od_gracza_wiersz,Plansza[wsp_od_gracza_kolumna,wsp_od_gracza_wiersz]);
    punktacja:=punktacja+((max_blok-1)*(max_blok-1));
    for i:='a' to max_kolumny do if grawitacja_kolumn[i]=1 then grawitacja_pionowa(i);
    grawitacja_pozioma;
    writeln('wynik: ',punktacja);
    wypisz_plansze;
  end;
end;

procedure ruch_komputera(znaki : String);			//procedura wykonujaca ruch komputera
var i : Char;
begin
  inteligencja(Plansza,znaki);					//znajduje najwiekszy blok mozliwy do usuniecia
  if max_blok>1 then						//jesli sklada sie on z minimum 2 elementow to jest on usuwany, zostaje zmieniona punktacja
  begin								//wykonywana jest grawitacja, wypisywany jest ruch komputera, punktacja oraz plansza
    usun_blok(wsp_kolumn_najlepszy_blok,wsp_wierszy_najlepszy_blok,Plansza[wsp_kolumn_najlepszy_blok,wsp_wierszy_najlepszy_blok]);
    punktacja:=punktacja-((max_blok-1)*(max_blok-1));
    for i:='a' to max_kolumny do if grawitacja_kolumn[i]=1 then grawitacja_pionowa(i);
    grawitacja_pozioma;
    writeln('(',wsp_kolumn_najlepszy_blok,wsp_wierszy_najlepszy_blok,')');
    writeln('wynik: ',punktacja);
    wypisz_plansze;
  end;
end;

begin
punktacja:=0;
dalej:=true;
if kto_zaczyna=1 then					//jesli kto_zaczyna=1 to pierwszy ruch wykonnuje gracz
  begin
    while (max_blok>1) and (not eof) do			//petla wykonuje sie dopoki nie skoncza sie dane lub komputer nie bedzie mogl usunac bloku
    begin
      ruch_gracza(znaki_gracz1);
      if poprawne then ruch_komputera(znaki_gracz2);
    end;
  end
  else begin						//w przeciwnym przypadku gra rozpoczyna komputer
    while (max_blok>1) and (not eof) do
    begin
      ruch_komputera(znaki_gracz1);
      if max_blok>1 then
      begin
	ruch_gracza(znaki_gracz2);
	if not poprawne then dalej:=false;
      end;
    end;
    if dalej then ruch_komputera(znaki_gracz1);		//jesli not dalej tzn. ze wykonany zostal ruch komputera, nastepnie zostaly wczytane niepoprawne
  end;							//dane i zakonczyl sie plik
end;

begin							//program glowny
  start;
  gra;
end. 