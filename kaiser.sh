#!/bin/sh
echo -e "*********************************************"
echo -e "   Script Integracao com BitBucket Auto Deploy"
echo -e "*********************************************"
echo -e ""

echo "INFORME O NOME DO USUARIO DO SERVERPILOT"
read USUARIO
if [ $USUARIO = "" ]; then
	echo "INFORME O NOME DO USUARIO DO SERVERPILOT"
	echo "execute novamente o script"
	exit
fi


echo "INFORME O NOME DO APP DO SERVERPILOT"
read APPSP
if [ $APPSP = "" ]; then
	echo "INFORME O NOME DO APP DO SERVERPILOT (normalmente serverpilot)"
	echo "execute novamente o script"
	exit
fi

echo "INFORME O SEU DOMINIO exemplo: seusite.com"
read DOMINIO
if [ $DOMINIO = "" ]; then
	echo "INFORME O SEU DOMINIO exemplo: seusite.com"
	echo "execute novamente o script"
	exit
fi

echo "INFORME O NOME DO PHP DESEJADO (exemplo: bit-deploy.php)"
read ARQUIVOPHP
if [ $ARQUIVOPHP = "" ]; then
	echo "INFORME O NOME DO APP DO SERVERPILOT"
	echo "execute novamente o script"
	exit
fi


echo "INFORME O ENDERECO DO SEU REPO NO BITBUCKET (exemplo: git@bitbucket.org:usuario/repositorio.git)"
read REPOSITORIO
if [ $REPOSITORIO = "" ]; then
	echo "INFORME O ENDERECO DO SEU REPO NO BITBUCKET (exemplo: git@bitbucket.org:usuario/repositorio.git)"
	read REPOSITORIO
fi

echo -e "Voce tem 5 segundos para cancelar a execucao antes que comece"
echo -e "Use CTRL + C para cancelar!"
sleep 5
echo "Vamos Trabalhar..."
cd /srv/users/$USUARIO/apps/$APPSP
git clone --mirror $REPOSITORIO repo
echo "Repositorio Clonado";
cd repo
GIT_WORK_TREE="GIT_WORK_TREE=/srv/users/$USUARIO/apps/$APPSP/public git checkout -f master"
echo "Repositorio Clonado"
echo "Vamos criar o php $ARQUIVOPHP"
echo "<?php
\$repo_dir = '/srv/users/$USUARIO/apps/$APPSP/repo';
\$web_root_dir = '/srv/users/$USUARIO/apps/$APPSP/public';

// Full path to git binary is required if git is not in your PHP user's path. Otherwise just use 'git'.
\$git_bin_path = 'git';

\$update = false;

// Parse data from Bitbucket hook payload
\$payload = json_decode($_POST['payload']);

if (empty(\$payload->commits)){
  // When merging and pushing to bitbucket, the commits array will be empty.
  // In this case there is no way to know what branch was pushed to, so we will do an update.
  \$update = true;
} else {
  foreach (\$payload->commits as \$commit) {
    \$branch = \$commit->branch;
    if (\$branch === 'master' || isset(\$commit->branches) && in_array('master', \$commit->branches)) {
      \$update = true;
      break;
    }
  }
}

if (\$update) {
  // Do a git checkout to the web root
  exec('cd ' . \$repo_dir . ' && ' . \$git_bin_path  . ' fetch');
  exec('cd ' . \$repo_dir . ' && GIT_WORK_TREE=' . \$web_root_dir . ' ' . \$git_bin_path  . ' checkout -f');

  // Log the deployment
  \$commit_hash = shell_exec('cd ' . \$repo_dir . ' && ' . \$git_bin_path  . ' rev-parse --short HEAD');
  file_put_contents('deploy.log', date('m/d/Y h:i:s a') . \" Deployed branch: \" .  \$branch . \" Commit: \" . \$commit_hash . \"\n\", FILE_APPEND);
}
?>" > /srv/users/$USUARIO/apps/$APPSP/public/$ARQUIVOPHP
echo "Arquivo Criado"
echo "Trabalho Concluido"
echo  "***************************************"
echo  "      RESULTADO FINAL DO SCRIPT 	    "
echo  "---------------------------------------"
echo  "------Dados para Configurar o Bitbucket------"
echo  "URL POST: http://$DOMINIO/$ARQUIVOPHP"
echo  "****************************************"
echo  "instalacao completa, por favor configure o webhook no bitbucket"
echo  "Apos configurar o webhoot e so realizar commits no ramo master e"
echo  " push pro origin que sera automaticamente enviado ao servidor"
echo  "Script Criado por Shirleyson Kaisser"
echo  "Configuracao de Servidores e muito mais."
echo  "skaisser@gmail.com"
echo "---------------------------------"

