--------------- SQL ---------------

CREATE OR REPLACE FUNCTION pre.ft_memoria_det_ime (
  p_administrador integer,
  p_id_usuario integer,
  p_tabla varchar,
  p_transaccion varchar
)
RETURNS varchar AS
$body$
/**************************************************************************
 SISTEMA:		Sistema de Presupuesto
 FUNCION: 		pre.ft_memoria_det_ime
 DESCRIPCION:   Funcion que gestiona las operaciones basicas (inserciones, modificaciones, eliminaciones de la tabla 'pre.tmemoria_det'
 AUTOR: 		 (admin)
 FECHA:	        01-03-2016 14:23:08
 COMENTARIOS:	
***************************************************************************
 HISTORIAL DE MODIFICACIONES:

 DESCRIPCION:	
 AUTOR:			
 FECHA:		
***************************************************************************/

DECLARE

	v_nro_requerimiento    	integer;
	v_parametros           	record;
	v_id_requerimiento     	integer;
	v_resp		            varchar;
	v_nombre_funcion        text;
	v_mensaje_error         text;
	v_id_memoria_det		integer;
    v_registros				record;
    v_registros_mem			record;
    v_importe				numeric;
			    
BEGIN

    v_nombre_funcion = 'pre.ft_memoria_det_ime';
    v_parametros = pxp.f_get_record(p_tabla);

	

	/*********************************    
 	#TRANSACCION:  'PRE_MDT_MOD'
 	#DESCRIPCION:	Modificacion de registros
 	#AUTOR:		admin	
 	#FECHA:		01-03-2016 14:23:08
	***********************************/

	if(p_transaccion='PRE_MDT_MOD')then

		begin
			
            select 
              md.id_memoria_det,
              md.importe
            into
              v_registros  
            from pre.tmemoria_det md 
            where md.id_memoria_det = v_parametros.id_memoria_det;
            
            select 
              mc.id_memoria_calculo,
              mc.importe_total
            into
              v_registros_mem  
            from pre.tmemoria_calculo mc 
            where mc.id_memoria_calculo = v_parametros.id_memoria_calculo;
            
           
            
            --Sentencia de la modificacion
			update pre.tmemoria_det set
              importe = v_parametros.importe,
              id_periodo = v_parametros.id_periodo,
              id_memoria_calculo = v_parametros.id_memoria_calculo,
              fecha_mod = now(),
              id_usuario_mod = p_id_usuario,
              id_usuario_ai = v_parametros._id_usuario_ai,
              usuario_ai = v_parametros._nombre_usuario_ai
			where id_memoria_det = v_parametros.id_memoria_det;
            
            
             
            v_importe = v_registros_mem.importe_total - v_registros.importe  + v_parametros.importe;
            
            update pre.tmemoria_calculo set
              importe_total = v_importe
            where  id_memoria_calculo = v_parametros.id_memoria_calculo;
               
			--Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Detalle de Memoria modificado(a)'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_memoria_det',v_parametros.id_memoria_det::varchar);
               
            --Devuelve la respuesta
            return v_resp;
            
		end;

	
         
	else
     
    	raise exception 'Transaccion inexistente: %',p_transaccion;

	end if;

EXCEPTION
				
	WHEN OTHERS THEN
		v_resp='';
		v_resp = pxp.f_agrega_clave(v_resp,'mensaje',SQLERRM);
		v_resp = pxp.f_agrega_clave(v_resp,'codigo_error',SQLSTATE);
		v_resp = pxp.f_agrega_clave(v_resp,'procedimientos',v_nombre_funcion);
		raise exception '%',v_resp;
				        
END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100;