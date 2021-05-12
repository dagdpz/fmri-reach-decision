#' @title dispersion parameter extraction
#' @description determines dispersion parameter for models fitted using various functions
#' @param x model result.
#' @return dispersion parameter.
#' @details supports models fitted using \code{glm}, \code{glm.nb\{MASS\}}, \code{glmer\{lme4\}}, \code{glmer.nb\{lme4\}},
#' \code{zeroinfl\{pscl\}}, and \code{glmmTMB\{glmmTMB\}} fitted with family being one of binomial, poisson, beta, nbinom1, nbinom2, or Gamma.
#' @examples
#' m=glm(rpois(n=50, lambda=pi)~1, family=poisson)
#' disp.par(m)
#' @export	
disp.par<-function(x){
  ##last updated Nov 26 2019
  ##additions/changes: bugfix for zeroinfl; deals with glmmTMB (beta and nbinom family)
  ##function needed for Gamma family:
  if(class(x)[[1]]!="glmmTMB"){
    pr=residuals(x, type ="pearson")
    sum.dp=sum(pr^2)
  }
  n.model.terms=NULL
  if(class(x)[[1]]=="glmerMod"){
    n.model.terms=length(fixef(x))+nrow(as.data.frame(summary(x)$varcor))
    if(family(x)$family%in%c("negative.binomial", "Gamma", "inverse.gaussian")){
			n.model.terms=n.model.terms+1
			#browser()
			if(family(x)$family=="inverse.gaussian"){
				if(family(x)$link=="log"){
					pr=as.vector(residuals(x, type ="response"))
					fitted.var=(fitted(x)^3)/(1/sigma(x))
					sum.dp = sum((pr/sqrt(fitted.var))^2)
				}else{
					stop("inverse Gaussian with link other than log isn't supported")
				}
			}
		}
  }else if(class(x)[[1]]=="glm"){
		n.model.terms=length(x$coefficients)
		if(class(x)[[1]]=="negbin"){
			n.model.terms=n.model.terms+length(summary(x)$theta)
		}else if(family(x)$family%in%c("Gamma", "inverse.gaussian")){
			n.model.terms=n.model.terms+1
			if(family(x)$family=="inverse.gaussian"){				
				if(x$family$link=="log"){
					pr=as.vector(residuals(x, type ="response"))
					fitted.var=(fitted(x)^3)/(1/summary(x)$dispersion)
					sum.dp = sum((pr/sqrt(fitted.var))^2)
				}else{
					stop("inverse Gaussian with link other than log isn't supported")
				}
			}
		}
  }else if(class(x)[[1]]=="zeroinfl"){
    n.model.terms=sum(unlist(lapply(x$coefficients, length)))
    n.model.terms=n.model.terms+length(summary(x)$theta)
  }else if(class(x)[[1]]=="betareg"){
    n.model.terms=sum(unlist(lapply(x$coefficients, length)))
  }else if(class(x)[[1]]=="glmmTMB"){
    print("caution: support for models of class glmmTMB is experimental and embryonic")
    print("and don't worry if it takes some time")
    #n.model.terms=sum(unlist(lapply(fixef(x), length)))+nrow(extract.ranef.from.glmmTB(x))
    pr=residuals(x, type ="response")
    if(x$modelInfo$family$family=="poisson"){
      fitted.var = fitted(x)
    }else{
      #model.terms=attr(terms(x$call$dispformula), "term.labels")#attr(terms(x$call$dispformula), "intercept")
      sigma.f=exp(as.vector(model.matrix(object=x$call$dispformula, data=x$frame)[, names(fixef(x)$disp), drop=F]%*%fixef(x)$disp))
      if(x$modelInfo$family$family=="nbinom2"){
        fitted.var = fitted(x)*(1+fitted(x)/sigma.f)#fitted(x) + fitted(x)^2/sigma(x)
      }else if(x$modelInfo$family$family=="nbinom1"){
        fitted.var = fitted(x)*(1+sigma.f)#fitted(x) + fitted(x)/sigma(x)
      }else if(x$modelInfo$family$family=="beta"){
        xfitted=fitted(x)
        shape1 = xfitted * sigma.f
        shape2 = (1 - xfitted) * sigma.f
        #xfitted(1-xfitted)/(1+sigma(x))#according to the glmmTMB help page for sigma
        fitted.var = shape1*shape2/((shape1+shape2)^2*(shape1+shape2+1))
      }else if(x$modelInfo$family$family=="Gamma"){
        #x.disp=exp(as.vector(model.matrix(object=x$call$dispformula, data=x$frame)%*%log(sigma(x))))
        xx=gamma.par.transf(mean=fitted(x), var=NULL, shape=1/sigma.f, scale=NULL)
        fitted.var = xx$var
        xdf=length(residuals(x))-n.model.terms
      }
    }
    
    n.model.terms=sum(c(unlist(lapply(fixef(x), length))), nrow(extract.ranef.glmmTMB(x)))
    #xdf=length(pr)-n.model.terms
    sum.dp=sum((pr/sqrt(fitted.var))^2)
    #if(as.numeric(substr(sessionInfo()[["otherPkgs"]][["glmmTMB"]]$Version, start=1, stop=1))>0){
    #sum.dp=sum(residuals(x, type ="pearson")^2)
    #}
  }
  if(!is.null(n.model.terms)){
    xdf=length(pr)-n.model.terms
    #return(data.frame(chisq=sum.dp, df=xdf, P=1-pchisq(sum.dp, xdf), dispersion.parameter=sum.dp/xdf))
    return(as.vector(sum.dp/xdf))
  }else{
    stop("model isn't of any of the currently supported classes (glm, negbin, begareg, zeroinfl, glmerMod, glmmTMB) or error distributions")
  }
}
