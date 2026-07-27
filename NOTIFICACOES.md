# Notificações de contas a pagar (ntfy)

O app já dispara o lembrete de contas que **vencem hoje** quando você **abre o app**
(alerta na tela + push no ntfy, se o tópico estiver configurado em *Agenda › Notificações*).

Para receber o alerta **mesmo com o app fechado**, é preciso algo que rode sozinho no
servidor todos os dias. O caminho mais simples é uma **Edge Function no Supabase + Cron**.

## Passo a passo (opcional, com o app fechado)

1. No celular, instale o app **ntfy** e inscreva-se num tópico, ex: `casa-adrian-larissa`.
   Coloque esse mesmo tópico em *Agenda › Notificações* dentro do Balizador.

2. No Supabase do app (projeto `dhnwdkulunvubrittkvq`), crie uma Edge Function
   `lembrete-contas` com este conteúdo:

```ts
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

Deno.serve(async () => {
  const sb = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
  );
  const TOPICO = "casa-adrian-larissa"; // <- seu tópico ntfy

  const hoje = new Date().getDate();
  const { data } = await sb.from("compromissos")
    .select("*").eq("tipo", "pagar").eq("ativo", true).eq("dia", hoje);

  for (const c of data ?? []) {
    await fetch(`https://ntfy.sh/${TOPICO}`, {
      method: "POST",
      headers: { "Title": "Conta vence hoje", "Tags": "moneybag" },
      body: `💸 ${c.titulo} — R$ ${Number(c.valor).toLocaleString("pt-BR")}`,
    });
  }
  return new Response("ok");
});
```

3. Agende para rodar todo dia de manhã (SQL Editor do Supabase):

```sql
select cron.schedule(
  'lembrete-contas-diario',
  '0 11 * * *',  -- 11:00 UTC = 08:00 no horário de Brasília
  $$ select net.http_post(
       url := 'https://dhnwdkulunvubrittkvq.functions.supabase.co/lembrete-contas',
       headers := '{"Authorization":"Bearer SEU_ANON_OU_SERVICE_KEY"}'::jsonb
     ); $$
);
```

> As extensões `pg_cron` e `pg_net` precisam estar habilitadas (Database › Extensions).

Se preferir, me chame que eu te guio nesse passo do servidor quando quiser ligar o
alerta com o app fechado.
