
# Basic Apache configuration

Desenvolvi esse script com o intuito de facilitar configurações simples de segurança em servidores apache.

Esse script foi baseado nas configurações padrões do Apache

## Funcionalidades

- Mod_evasive install
- Mod_security install
- Desabilita listagem de diretorios (index of)
- Banner grabbing



## Autores

- [@oogaara](https://www.github.com/oogaara)


## Uso / Exemplos

```bash
sudo ./basicapache.sh
```
_obs: você precisa configurar o seu `mod_evasive` manualmente_.

`sudo nano /etc/apache2/mods-enabled/evasive.conf`

você pode seguir os seguintes passos:
[mode_evasive configuration](https://www.rapid7.com/blog/post/2017/04/09/how-to-configure-modevasive-with-apache-on-ubuntu-linux/)
