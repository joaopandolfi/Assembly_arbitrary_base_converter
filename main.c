#include <stdio.h>
#include <stdlib.h>

// ======================= ESTRUTURA ========================
typedef struct valor
{
    char original[18];
    char binario[16];
    char hexa[4];
    int decimal;
} Valor;

// =================== FUNÇÕES AUXILIARES ====================
//calcula X^Y
int potencia(int base, int exp)
{
    int cont=0;
    int val = 1;
    if(exp == 0)
        return 1;
    while (cont<exp)
    {
        val = val * base;
        cont++;
    }
    return val;
}

//converte Int para Char
char NumToChar(int val)
{
	if(val>=10)
		return(val+55);
	else if(val>=0 && val<=9 )
		return(val+48);
}

//converte Char para Int //otimizar
int CharToNum(char val)
{
	if(val>=65)
		return(val-55);
	else if(val>=48 && val<=57 )
		return(val-48);
}

//limpa vetor
void Limpa(Valor *num)
{
	int i=0;
	//limpa o vetor hexa
	while (i<=4)
	{
		num->hexa[i] = '\0';
		i++;
	}
	i=0;
	//limpa o vetor binario
	while (i<16)
	{
		num->binario[i] = '\0';
		i++;
	}
	i=0;
	//limpa o vetor original
	while (i<18)
	{
		num->original[i] = '\0';
		i++;
	}
	//limpa valor decimal
	num->decimal = 0;
}

// ================= FUNÇÕES DO PROBLEMA =================

//identifica a base do valor inserido pelo usuario
int IdentificaBase(Valor *num)
{
	int i,j;
	if(num->original[0] == '0' && num->original[1] =='b') //binario
	{
		i = 0;
		j = 2;
		while(num->original[j] != '\0' && j<18)
		{
			num->binario[i] = num->original[j];
			i++;
			j++;
		}
		return 1;
	}
	else if(num->original[0] == '0' && num->original[1] =='x') //hexa
	{
		i = 0;
		j = 2;
		while(num->original[j] != '\0' && j<6)
		{
			num->hexa[i] = num->original[j];
			i++;
			j++;
		}
		return 3;
	}
	else
	{
		i=0;
		j=0;
		//pego tamanho do numero
		while (num->original[i] != '\0' && i<18)
			i++;
		i--;
		while (i>=0)
		{
			num->decimal = num->decimal + (potencia(10,i)*CharToNum(num->original[j]));
			i--;
			j++;
		}
		return 2;
	}
}

void ConverteDecParaBin(int origem, char destino[])
{
	//declaração de inicialização
	char aux[16];
    int quociente,resto,i,j;
    quociente = resto = i = j = 0;
    //primeira iteração
    quociente = origem /2;
    resto = origem%2;
    aux[i] = NumToChar(resto);
    //o resto das iterações
    while (quociente != 0)
    {
        i++;
        origem = quociente;
        quociente = origem /2;
        resto = origem%2;
        aux[i] = NumToChar(resto);
    }
    //inverte sentença
    while(i>=0)
    {
		destino[j] = aux[i];
		i--;
		j++;
	}
}

void ConverteDecParaHex(int origem, char destino[])
{
    //declaração de inicialização
    int quociente,resto,i;
    quociente = resto = i = 0;
    //primeira iteração
    quociente = origem /16;
    resto = origem%16;
    destino[i] = NumToChar(resto);
    while (quociente != 0)
    {
        i++;
        origem = quociente;
        quociente = origem /16;
        resto = origem%16;
        destino[i] = NumToChar(resto);
    }
}

void ConverteHexParaDec(char origem[4],int *destino)
{
    int i,cont;
    //inicializo variaveis
    *destino = i = cont =  0;
    //conto a quantidade de caracteres
    while (origem[i] != '\0' && cont<16)
    {
        cont++;
        i++;
    }
    cont--;
    i=0;
    //calculo da base
    while(cont>=0)
    {
        *destino = *destino + (potencia(16,cont)*CharToNum(origem[i]));
        cont--;
        i++;
    }
}

void ConverteBinParaDec(char origem[16], int *destino)
{
    int i,cont;
    //inicializo variaveis
    *destino = i = cont =  0;
    //conto a quantidade de caracteres
    while (origem[i] != '\0' && cont<16)
    {
        cont++;
        i++;
    }
    cont--;
    i=0;
    //calculo da base
    while(cont>0)
    {
        if(origem[i] == '1')
            *destino = *destino + potencia(2,cont);
        cont--;
        i++;
    }
}

// =================== PROGRAMA PRINCIPAL ====================

void main()
{
	//crio a estrutura
    Valor num;
    int aux;
    //limpa valores
    Limpa(&num);
    //leio o primeiro valor do teclado
    printf("Digite o Valor a ser Convertido: ");
    scanf("%s",&num.original);
    aux = IdentificaBase(&num);
    //faz conversoes
    if(aux == 1) //binario
    {
		ConverteBinParaDec(num.binario,&num.decimal);
		ConverteDecParaHex(num.decimal,&num.hexa);
    }
    else if (aux == 2) //decimal
	{
		ConverteDecParaHex(num.decimal,&num.hexa);
		ConverteDecParaBin(num.decimal,&num.binario);
    }
    else //hexa
	{
		ConverteHexParaDec(num.hexa,&num.decimal);
		ConverteDecParaBin(num.decimal,&num.binario);
	}
    printf("Valor em Dec: %d\n",num.decimal);
    printf("Valor em Hexa: %s\n",&num.hexa);
    printf("Valor em Bin: %s\n",&num.binario);
}
