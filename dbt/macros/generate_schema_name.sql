{% macro generate_schema_name(custom_schema_name, node) -%}

    {%- if target.name == 'cicd' and custom_schema_name is not none -%}

        {{ custom_schema_name | trim | lower }}

    {%- elif custom_schema_name is not none -%}

        {{ '_' ~ custom_schema_name ~ '_' ~ target.schema | trim | lower }}

    {%- else -%}

        {{ target.schema | trim | lower }}

    {%- endif -%}

{%- endmacro %}
