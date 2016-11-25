/* DEFINICIONES */

BLANCO (\ |\t|\n)+
COMILLA_DOBLE \"

NUMERO_VERSION 1\.[0-9]+
VERSION <\?xml{BLANCO}version{BLANCO}?={BLANCO}?{COMILLA_DOBLE}{NUMERO_VERSION}{COMILLA_DOBLE}\?>

CARACTER_INICIAL_NOMBRE :|[A-Z]|_|[a-z]
CARACTER_NOMBRE {CARACTER_INICIAL_NOMBRE}|-|\.|[0-9]
NOMBRE {CARACTER_INICIAL_NOMBRE}({CARACTER_NOMBRE})*
NOMBRES {NOMBRE}(\ {NOMBRE})*

TAG_SIGNO_PREGUNTA <\?.*\?>
TAG_SIGNO_EXCLAMACION <!.*>

CUALQUIER_CARACTER_EXCEPTO_COMILLA_DOBLE [^"]
STRING_COMILLA {COMILLA_DOBLE}{CUALQUIER_CARACTER_EXCEPTO_COMILLA_DOBLE}*{COMILLA_DOBLE}
ATRIBUTO {NOMBRE}={STRING_COMILLA}

ABRE_TAG_SIMPLE <{NOMBRE}>
ABRE_TAG <{NOMBRE}(\ {ATRIBUTO})*>
CIERRA_TAG <\/{NOMBRE}>

%{
	int offset = 0; // debe ser cero o uno?
	int tags_abiertos = 0;
	int tags_cerrados = 0;
	char stack[1024][1024];
%}

%%

{VERSION} {
	printf("VERSION");
}

{TAG_SIGNO_PREGUNTA} {
	printf("TAG_SIGNO_PREGUNTA");
}

{TAG_SIGNO_EXCLAMACION} {
	printf("TAG_SIGNO_EXCLAMACION");
}

{ABRE_TAG_SIMPLE} {
	fprintf(stderr, "Apilando %s...\n", yytext);
	strcpy(stack[tags_abiertos], yytext);
	tags_abiertos++;
}

{ABRE_TAG} {
	fprintf(stderr, "Apilando %s...\n", yytext);
	strcpy(stack[tags_abiertos], yytext);
	tags_abiertos++;
}

{CIERRA_TAG} {
	tags_abiertos--;
	fprintf(stderr, "tags_abiertos: %d\n", tags_abiertos);
	fprintf(stderr, "yytext: %s\n", yytext);
	fprintf(stderr, "stack: %s\n", stack[tags_abiertos - offset]);
	fprintf(stderr, "Desempilando %s...\n", stack[tags_abiertos]);

	char* nombre_tag_leido = &yytext[2];
	char* nombre_tag_tope_stack = &stack[tags_abiertos - offset][1];
	int largo_tags = yyleng - 3;
	if (strncmp(nombre_tag_leido, nombre_tag_tope_stack, largo_tags)) {
		printf("ERROR: falta cerrar el tag %s\n", stack[tags_abiertos - offset]);
		exit(1);
	}
}


%%


/* CODIGO USUARIO */
int main(int argc, char* argv[])
{
	yyin = fopen(argv[1], "r");
	yylex();
	fclose(yyin);
	if (tags_abiertos != 0)
	{
		printf("hay %d tag(s) sin cerrar\n", tags_abiertos);
		return 2;
	}
	printf("No se encontraron errores en el documento.\n");
	// printf("TAGS ABIERTOS: %d\n", tags_abiertos);
}
