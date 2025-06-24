# Procedure de Envio de E-mail - Avaliações de fornecedores duplicadas.

Este projeto contém uma procedure (função no banco de dados Oracle) que envia um e-mail com informações sobre deleções de avaliaçoes de fornecedores duplicadas.

## Objetivo

O objetivo principal desta procedure é ** deletar quando houver uma avaliação duplicada e enviar um e-mail informando a deleção** com dados como:

- Número da entrada da nota
- Avaliação duplicada para o fornecedor que esta na nota.

Essas informações são mostradas em um modelo de e-mail em HTML, pronto para ser enviado.

## Como funciona

A JOB do banco de dados chama a procedure a cada hora, onde é feita a deleção de avaliação duplicada e dispara o e-mail.

1. Busca dados da nota correspondente no banco de dados
2. Monta o conteúdo do e-mail com HTML

Tudo isso é feito de forma automática, sem precisar escrever o e-mail manualmente.

## Tecnologias utilizadas

- Oracle PL/SQL
- Banco de dados relacional
- HTML para formatar o e-mail

## Uso

Esta procedure pode ser útil para sistemas que:

- Fazem conferência de nota fiscal
- Precisam enviar relatórios por e-mail
- Querem automatizar esse processo e ganhar tempo

---

> ⚠️ Atenção: este código é genérico e não utiliza dados reais de notas fiscais. Foi adaptado para fins de exemplo.

## Autor

Desenvolvido por Gabriel Lisboa 👨‍💻
