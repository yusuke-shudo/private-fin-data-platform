{% macro generate_schema_name(custom_schema_name, node) -%}

    {%- if target.name == 'dev' and custom_schema_name is not none -%}

        {{ '_' ~ target.schema ~ '_' ~ custom_schema_name | trim | lower }}

    {%- elif target.name == 'cicd' and custom_schema_name is not none -%}

        {{ custom_schema_name | trim | lower }}

    {%- elif custom_schema_name is not none -%}

        {{ custom_schema_name | trim | upper }}

    {%- else -%}

        {{ target.schema | trim | lower }}

    {%- endif -%}

{%- endmacro %}
