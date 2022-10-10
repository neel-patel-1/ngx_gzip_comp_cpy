
/*
 * Copyright (C) Maxim Dounin
 */

#include <ngx_config.h>
#include <ngx_core.h>
#include <ngx_http.h>


typedef struct {
    ngx_flag_t         enable;
} ngx_http_comp_copy_conf_t;


static void *ngx_http_comp_copy_create_conf(ngx_conf_t *cf);
static char *ngx_http_comp_copy_merge_conf(ngx_conf_t *cf, void *parent,
    void *child);
static ngx_int_t ngx_http_comp_copy_init(ngx_conf_t *cf);


static ngx_command_t  ngx_http_comp_copy_commands[] = {

    { ngx_string("comp_copy"),
      NGX_HTTP_MAIN_CONF|NGX_HTTP_SRV_CONF|NGX_HTTP_LOC_CONF|NGX_CONF_FLAG,
      ngx_conf_set_flag_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_comp_copy_conf_t, enable),
      NULL },

      ngx_null_command
};


static ngx_http_module_t  ngx_http_comp_copy_module_ctx = {
    NULL,                          /* preconfiguration */
    ngx_http_comp_copy_init,      /* postconfiguration */

    NULL,                          /* create main configuration */
    NULL,                          /* init main configuration */

    NULL,                          /* create server configuration */
    NULL,                          /* merge server configuration */

    ngx_http_comp_copy_create_conf, /* create location configuration */
    ngx_http_comp_copy_merge_conf   /* merge location configuration */
};


ngx_module_t  ngx_http_comp_copy_filter_module = {
    NGX_MODULE_V1,
    &ngx_http_comp_copy_module_ctx, /* module context */
    ngx_http_comp_copy_commands,  /* module directives */
    NGX_HTTP_MODULE,               /* module type */
    NULL,                          /* init master */
    NULL,                          /* init module */
    NULL,                          /* init process */
    NULL,                          /* init thread */
    NULL,                          /* exit thread */
    NULL,                          /* exit process */
    NULL,                          /* exit master */
    NGX_MODULE_V1_PADDING
};


static ngx_http_request_body_filter_pt   ngx_http_next_request_body_filter;


static ngx_int_t
ngx_http_comp_copy_filter(ngx_http_request_t *r, ngx_chain_t *in)
{
    ngx_chain_t                 *cl;
    ngx_http_comp_copy_conf_t  *conf;
	ngx_buf_t 					*dbuf;

    conf = ngx_http_get_module_loc_conf(r, ngx_http_comp_copy_filter_module);

    if (!conf->enable) {
        return ngx_http_next_request_body_filter(r, in);
    }

    ngx_log_debug0(NGX_LOG_DEBUG_HTTP, r->connection->log, 0,
                   "comp copy body filter");

    for (cl = in; cl; cl = cl->next) {

		/* copy all data to d_buf */
		dbuf = ngx_calloc_buf(r->pool);
		dbuf->pos = (unsigned char *)ngx_pnalloc(r->pool, ngx_buf_size(cl->buf)); 

		memcpy(dbuf->pos, cl->buf, ngx_buf_size(cl->buf));
		ngx_log_debug1(NGX_LOG_DEBUG_HTTP, r->connection->log, 0,
					   "comp copy buf of size:%d", ngx_buf_size(cl->buf));

    }

    return ngx_http_next_request_body_filter(r, in);
}


static void *
ngx_http_comp_copy_create_conf(ngx_conf_t *cf)
{
    ngx_http_comp_copy_conf_t  *conf;

    conf = ngx_pcalloc(cf->pool, sizeof(ngx_http_comp_copy_conf_t));
    if (conf == NULL) {
        return NULL;
    }

    conf->enable = NGX_CONF_UNSET;

    return conf;
}


static char *
ngx_http_comp_copy_merge_conf(ngx_conf_t *cf, void *parent, void *child)
{
    ngx_http_comp_copy_conf_t *prev = parent;
    ngx_http_comp_copy_conf_t *conf = child;

    ngx_conf_merge_value(conf->enable, prev->enable, 0);

    return NGX_CONF_OK;
}


static ngx_int_t
ngx_http_comp_copy_init(ngx_conf_t *cf)
{
    ngx_http_next_request_body_filter = ngx_http_top_request_body_filter;
    ngx_http_top_request_body_filter = ngx_http_comp_copy_filter;

    return NGX_OK;
}
