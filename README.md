# Estructura del Código

## VPC y Subredes
La VPC se define utilizando el recurso aws_vpc. Se crean dos subredes públicas y dos subredes privadas, cada una en una zona de disponibilidad diferente, utilizando el recurso aws_subnet. Las subredes públicas están asociadas con las instancias y el balanceador de carga, mientras que las subredes privadas se utilizan para aislar las instancias.

## Instancias EC2 y Servidores Web
Se lanzan dos instancias EC2 en las subredes públicas definidas. El recurso aws_instance se utiliza para crear estas instancias. En el bloque user_data, se especifica un script de inicio que configura un servidor web Apache en cada instancia y crea una página HTML con información sobre la instancia y la región.

## Grupo de Destinos (Target Group) y Balanceador de Carga
El recurso aws_lb_target_group crea un grupo de destinos para las instancias EC2. El balanceador de carga de Application Load Balancer se define usando aws_lb, con un listener que dirige el tráfico entrante al grupo de destinos. El tráfico se distribuye automáticamente entre las instancias para lograr alta disponibilidad y escalabilidad.