--------------- SQL ---------------

CREATE OR REPLACE FUNCTION pre.f_get_estado_presupuesto_mb_x_fechas (
  p_id_presupuesto integer,
  p_id_partida integer,
  p_tipo_movimiento varchar,
  p_fecha_ini date,
  p_fecha_fin date
)
RETURNS numeric AS
$body$
/**************************************************************************
 SISTEMA:		Sistema de Presupuesto
 FUNCION: 		pre.f_get_estado_presupuesto_mb_x_fechas
 DESCRIPCION:    
 AUTOR: 		 RAC (KPLIAN)
 FECHA:	        29-02-2016 19:40:34
 COMENTARIOS:	
***************************************************************************
 HISTORIAL DE MODIFICACIONES:

 DESCRIPCION:	
 AUTOR:			
 FECHA:		
***************************************************************************/

DECLARE

v_resp				varchar;
v_nombre_funcion	varchar;
v_importe			numeric;
 

BEGIN

      v_nombre_funcion = 'pre.f_get_estado_presupuesto_mb_x_fechas';
   
     -- si no tenemos numero de tramite
   
          
            select
                 sum(COALESCE(pe.monto_mb,0))
            into
                v_importe     
            from pre.tpartida_ejecucion pe
            where pe.id_presupuesto = p_id_presupuesto
                  and pe.id_partida = p_id_partida
                  and pe.tipo_movimiento = p_tipo_movimiento
                  and pe.estado_reg = 'activo'
                  and pe.fecha BETWEEN p_fecha_ini and p_fecha_fin;
      
     
      
      return COALESCE(v_importe,0);
      
      
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
STABLE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100;