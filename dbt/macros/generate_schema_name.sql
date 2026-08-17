{% macro generate_schema_name(custom_schema_name, node) -%}

    {%- if node.resource_type == 'seed' and custom_schema_name is not none -%}

        {{ custom_schema_name | trim | upper }}

    {%- elif target.name == 'cicd' and custom_schema_name is not none -%}

        {{ custom_schema_name | trim | lower }}

    {%- elif target.name == 'dev' and custom_schema_name is not none -%}

        {{ '_' ~ target.schema ~ '_' ~ custom_schema_name | trim | lower }}

    {%- else -%}

        {{ target.schema | trim | lower }}

    {%- endif -%}

{%- endmacro %}