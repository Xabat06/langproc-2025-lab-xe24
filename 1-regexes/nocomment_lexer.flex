%option noyywrap

%{

#include "nocomment.hpp"

// The following line avoids an annoying warning in Flex
// See: https://stackoverflow.com/questions/46213840/
extern "C" int fileno(FILE *stream);

int removed_cnt = 0;

%}

%x ESCAPE
%x ATTRIBUTE

%%

"//"[^\n]*\n {
  removed_cnt++;
}

\\ {
  BEGIN(ESCAPE);
  yylval.character = '\\';
  return Other;
}

<ESCAPE>" " {
  BEGIN(INITIAL);
  yylval.character = yytext[0];
  return Other;
}

<ESCAPE>\n {
  BEGIN(INITIAL);
  yylval.character = '\n';
  return Other;
}

<ESCAPE>. {
  yylval.character = yytext[0];
  return Other;
}

"(*" {
  removed_cnt++;
  BEGIN(ATTRIBUTE);
}

<ATTRIBUTE>"*)" {
  BEGIN(INITIAL);
}

<ATTRIBUTE>\\[^ \n]* {}

<ATTRIBUTE>"//"[^\n]* {}

<ATTRIBUTE>.|\n {}

\n {
  yylval.character = '\n';
  return Other;
}

. {
  yylval.character = yytext[0];
  return Other;
}

EOF {
  return Eof;
}

%%

/* Error handler. This will get called if none of the rules match. */
void yyerror (char const *s)
{
  fprintf (stderr, "Flex Error: %s\n", s);
  exit(1);
}
