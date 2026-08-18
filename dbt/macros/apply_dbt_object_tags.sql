{% macro apply_dbt_object_tags(results) %}

  {% for result in results if result and result.get('node') %}
    
    {% set relation = adapter.get_relation(
      database=result.node.database,
      schema=result.node.schema,
      identifier=result.node.alias
    ) %}

    {# relationが存在し、かつ対象のタイプである場合だけSQLを作る #}
    {% if relation and relation.type | lower in ['table', 'view', 'materialized_view', 'dynamic_table', 'external_table'] %}
      {% set sql %}
        ALTER {{ relation.type | upper }} {{ relation }} SET TAG OBJECT_MANAGED_BY = 'dbt';
      {% endset %}
      {% do run_query(sql) %}
    {% endif %}

  {% endfor %}

{% endmacro %}
