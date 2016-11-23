{%- set p  = salt['pillar.get']('kafka', {}) %}
{%- set g = salt['grains.get']('kafka', {}) %}

{%- set hosts_function       = g.get('hosts_function', p.get('hosts_function', 'network.get_hostname')) %}
{%- set hosts_target         = g.get('hosts_target', p.get('hosts_target', 'roles:kafka')) %}
{%- set targeting_method     = g.get('targeting_method', p.get('targeting_method', 'grain')) %}

{%- set kafka_host_dict = salt['mine.get'](hosts_target, hosts_function, targeting_method) %}
{%- set kafka_ids       = kafka_host_dict.keys() %}
{%- set kafka_hosts     = kafka_host_dict.values() %}

{%- set kafka_host_num   = kafka_ids | length() %}

{%- if kafka_host_num == 0
    or kafka_host_num is odd %}
  # 0 means Kafka nodes have not been found,
  # for 1, 3, 5 ... nodes just return the list
  {%- set node_count = kafka_host_num %}
{%- elif kafka_host_num is even %}
  # for 2, 4, 6 ... nodes return (n -1)
  {%- set node_count = kafka_host_num - 1 %}
{%- endif %}

# yes, this is not pretty, but produces sth like:
# {'node1': '0+node1', 'node2': '1+node2', 'node3': '2+node2'}
{%- set kafka_with_ids = {} %}
{%- for i in range(node_count) %}
  {%- if kafka_hosts[i] is string %}
    # get plain value from Zookeeper hosts fetched by the Mine function
    {%- set node_addr = kafka_hosts[i] %}
  {%- elif kafka_hosts[i] is sequence %}
    # if list provided, take the first value
    {%- set node_addr = kafka_hosts[i] | first() %}
  {%- else %}
    # skip any other values including nested dicts
    {%- set node_addr = '' %}
  {%- endif %}

  {%- if node_addr %}
    {%- do kafka_with_ids.update({kafka_ids[i] : '{0:d}'.format(i) + '+' + node_addr })  %}
  {%- endif %}
{%- endfor %}

# a plain list of hostnames
{%- set kafkas = kafka_with_ids.values() | sort() %}

# return either the id of the host or an empty string
{%- set broker_id = kafka_with_ids.get(grains.id, '').split('+') | first() %}
{%- set hostname = kafka_host_dict.get(grains.id, '') %}

{%- set k = {} %}
{%- do k.update( {
                    'broker_id': broker_id,
                    'hostname': hostname,
                  } ) %}
